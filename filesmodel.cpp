#include "filesmodel.h"

#include <QDesktopServices>
#include <QUrl>
#include <QAudioOutput>
#include <QtConcurrent/QtConcurrent>
#include <QFuture>

FilesModel::FilesModel(QObject *parent)
    : QAbstractListModel{parent}
{
    connect(this, &FilesModel::beginRefresh, this, &FilesModel::refreshFileList);

    m_currentDir = new QDir();
    m_currentDir->setSorting(QDir::DirsFirst | QDir::Name | QDir::IgnoreCase | QDir::LocaleAware);
    m_currentDir->setFilter(QDir::AllEntries | QDir::Hidden);

    m_watcher = new QFileSystemWatcher();
    // TODO: make this refresh a single entry instead of the whole list
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &FilesModel::refreshFileList);
    connect(m_watcher, &QFileSystemWatcher::directoryChanged, this, &FilesModel::refreshFileList);

    m_navigationSound = new QMediaPlayer();
    m_navigationSound->setSource(QUrl("qrc:/aero/misc/navStart.wav"));
    QAudioOutput *audioOutput = new QAudioOutput();
    m_navigationSound->setAudioOutput(audioOutput);
    
    m_contextMenu = new ContextMenu(this);
    connect(m_contextMenu, &ContextMenu::triggered, this, [this](const QString &actionName) {
        if(actionName == "copy") {
            copyFile(m_currentContextFileName);
        } else if(actionName == "cut") {
            cutFile(m_currentContextFileName);
        } else if(actionName == "paste") {
            pasteFile();
        } else if(actionName == "delete") {
            deleteFile(m_currentContextFileName);
        }
    });
}

// idk if this works lmao
FilesModel::~FilesModel()
{
    // or if this disconnection part is necessary
    disconnect(m_watcher, &QFileSystemWatcher::fileChanged, this, &FilesModel::refreshFileList);
    disconnect(m_watcher, &QFileSystemWatcher::directoryChanged, this, &FilesModel::refreshFileList);

    delete m_currentDir;
    delete m_watcher;

    delete m_navigationSound->audioOutput();
    delete m_navigationSound;

    if(m_loadingThread) {
        m_loadingThread->terminate();
        m_loadingThread->wait();
        delete m_loadingThread;
    }
}

int FilesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_files.length();
}

QVariant FilesModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() && index.row() < 0 && index.row() > m_files.length())
        return 0;

    QSharedPointer<FileDelegate> delegate = m_files.at(index.row());

    switch((FileRole) role) {
    case NameRole:
        return delegate->name;
    case IconNameRole:
        return delegate->iconName;
    case MimeTypeRole:
        return delegate->mimeType;
    case PathRole:
        return delegate->path;
    case ModifiedDateRole:
        return delegate->modifiedDate;
    case CreatedDateRole:
        return delegate->createdDate;
    case SizeRole:
        return delegate->size;
    case HiddenRole:
        return delegate->isHidden;
    case EmblemNameRole:
        return delegate->emblemName;
    }

    return QVariant();
}

QString FilesModel::currentDir()
{
    return m_currentDir->absolutePath();
}

void FilesModel::applyFileList(const QList<QSharedPointer<FileDelegate>> fileList)
{
    beginInsertRows(QModelIndex(), 0, fileList.length()-1);
    for(int i = 0; i < fileList.length(); i++) {
        QSharedPointer<FileDelegate> delegate = fileList[i];

        m_watcher->addPath(delegate->path);

        m_files.append(delegate);
    }
    endInsertRows();
    emit finishRefresh();
}

void FilesModel::refreshFileList()
{
    if(m_watcher->files().length() > 0)
        m_watcher->removePaths(m_watcher->files());

    beginResetModel();
    m_files.clear();
    endResetModel();

    if(m_loadingThread) {
        m_loadingThread->terminate();
        m_loadingThread->wait();
        delete m_loadingThread;
    }

    m_loadingThread = new FileFetcherThread();
    m_loadingThread->sdir = m_currentDir->absolutePath();
    m_loadingThread->sortingFlags = m_currentDir->sorting();
    m_loadingThread->filter = m_currentDir->filter();

    QObject::connect(m_loadingThread, &FileFetcherThread::loadingFinished, this, &FilesModel::applyFileList);

    m_loadingThread->start();
}

void FilesModel::setCurrentDir(const QString &newDir)
{
    m_canGoBack = m_backHistory.length() > 0;
    m_canGoForward = m_forwardHistory.length() > 0;

    m_currentDir->setPath(newDir);
    m_navigationSound->play();
    emit currentDirChanged();

    m_canGoUp = m_currentDir->absolutePath() != "/";
    emit beginRefresh();
}

QString FilesModel::currentDirIcon()
{
    return KIO::iconNameForUrl(QUrl::fromLocalFile(m_currentDir->absolutePath()));
}

void FilesModel::goBack()
{
    if(m_canGoBack) {
        const QString previousDir = m_currentDir->absolutePath();
        setCurrentDir(m_backHistory.at(m_backHistory.length()-1));
        m_backHistory.remove(m_backHistory.length()-1);
        m_forwardHistory.append(previousDir);

        m_canGoBack = m_backHistory.length() > 0;
        m_canGoForward = m_forwardHistory.length() > 0;
    }
}

bool FilesModel::canGoBack()
{
    return m_canGoBack;
}

void FilesModel::goForward()
{
    if(m_canGoForward) {
        const QString previousDir = m_currentDir->absolutePath();
        setCurrentDir(m_forwardHistory.at(m_forwardHistory.length()-1));
        m_forwardHistory.remove(m_forwardHistory.length()-1);
        m_backHistory.append(previousDir);

        m_canGoBack = m_backHistory.length() > 0;
        m_canGoForward = m_forwardHistory.length() > 0;
    }
}

bool FilesModel::canGoForward()
{
    return m_canGoForward;
}

void FilesModel::goUp()
{
    if(m_canGoUp) {
        m_backHistory.clear();
        m_forwardHistory.append(m_currentDir->absolutePath());

        m_canGoBack = m_backHistory.length() > 0;
        m_canGoForward = m_forwardHistory.length() > 0;

        m_currentDir->cdUp();
        setCurrentDir(m_currentDir->absolutePath());

        m_canGoUp = m_currentDir->absolutePath() != "/";
    }
}

bool FilesModel::canGoUp()
{
    return m_canGoUp;
}

QStringList FilesModel::history(const int &type)
{
    if(type == 0) return m_backHistory;
    if(type == 1) return m_forwardHistory;
    if(type == 2) return m_history;
    return QStringList();
}

void FilesModel::trigger(const int &index)
{
    if(index < 0 && index > m_files.length())
        return;

    QFileInfo file(m_files.at(index)->path);

    if(file.isDir()) {
        if(m_forwardHistory.length() > 0) {
            if(file.absoluteFilePath() != m_forwardHistory.at(0)) {
                m_forwardHistory.clear();
                m_canGoForward = m_forwardHistory.length() > 0;
            }
        }

        // There might be a better way to do this
        if(m_history.length() > 0) {
            bool dirToHistory = false;

            for(int i = 0; i < m_history.length(); i++)
                dirToHistory = m_history.at(i) != file.absolutePath();

            if(dirToHistory)
                m_history.emplaceFront(file.absolutePath());
        }
        else
            m_history.append(file.absolutePath());

        m_backHistory.append(file.absolutePath());

        setCurrentDir(file.absoluteFilePath());
    }
    else if(file.isExecutable())
        QProcess::startDetached(file.absoluteFilePath(), QStringList());
    else if(file.suffix() == "exe")
        QProcess::startDetached("wine", QStringList() << file.absoluteFilePath());
    else
        QDesktopServices::openUrl(QUrl::fromLocalFile(file.absoluteFilePath()));
}

void FilesModel::trigger(const QString &path)
{
    QFileInfo file(path);

    if(file.isDir()) {
        if(m_forwardHistory.length() > 0) {
            if(file.absoluteFilePath() != m_forwardHistory.at(0)) {
                m_forwardHistory.clear();
                m_canGoForward = m_forwardHistory.length() > 0;
            }
        }

        // There might be a better way to do this
        if(m_history.length() > 0) {
            bool dirToHistory = false;

            for(int i = 0; i < m_history.length(); i++)
                dirToHistory = m_history.at(i) != file.absolutePath();

            if(dirToHistory)
                m_history.emplaceFront(file.absolutePath());
        }
        else
            m_history.append(file.absolutePath());

        m_backHistory.append(m_currentDir->absolutePath());

        setCurrentDir(file.absoluteFilePath());
    }
    else if(file.isExecutable())
        QProcess::startDetached(file.absoluteFilePath(), QStringList());
    else if(file.suffix() == "exe")
        QProcess::startDetached("wine", QStringList() << file.absoluteFilePath());
    else
        QDesktopServices::openUrl(QUrl::fromLocalFile(file.absoluteFilePath()));
}

bool FilesModel::isValidDirectory(const QString &path)
{
    QDir dir(path);
    return dir.exists();
}

void FilesModel::copyFile(const QString &fileName)
{
    QString fullPath = m_currentDir->absoluteFilePath(fileName);
    QMimeData *mimeData = new QMimeData();
    mimeData->setUrls(QList<QUrl>() << QUrl::fromLocalFile(fullPath));
    
    QGuiApplication::clipboard()->setMimeData(mimeData);
    m_isCutOperation = false;
}

void FilesModel::cutFile(const QString &fileName)
{
    QString fullPath = m_currentDir->absoluteFilePath(fileName);
    QMimeData *mimeData = new QMimeData();
    mimeData->setUrls(QList<QUrl>() << QUrl::fromLocalFile(fullPath));
    
    QGuiApplication::clipboard()->setMimeData(mimeData);
    m_isCutOperation = true;
}

void FilesModel::pasteFile()
{
    const QMimeData *mimeData = QGuiApplication::clipboard()->mimeData();
    
    if(!mimeData->hasUrls())
        return;
    
    QList<QUrl> urls = mimeData->urls();
    
    for(const QUrl &url : urls) {
        QString sourcePath = url.toLocalFile();
        QString fileName = QFileInfo(sourcePath).fileName();
        QString destPath = m_currentDir->absoluteFilePath(fileName);
        
        if(m_isCutOperation) {
            QFile::rename(sourcePath, destPath);
        } else {
            QFile::copy(sourcePath, destPath);
        }
    }
    
    refreshFileList();
}

void FilesModel::deleteFile(const QString &fileName)
{
    QString fullPath = m_currentDir->absoluteFilePath(fileName);
    QFileInfo fileInfo(fullPath);
    
    if(fileInfo.isDir()) {
        QDir dir(fullPath);
        dir.removeRecursively();
    } else {
        QFile file(fullPath);
        file.remove();
    }
    
    refreshFileList();
}

void FilesModel::showContextMenu(int x, int y, const QString &fileName)
{
    m_currentContextFileName = fileName;
    
    bool canPaste = (QGuiApplication::clipboard()->mimeData() && 
                     QGuiApplication::clipboard()->mimeData()->hasUrls());
    
    m_contextMenu->clear();
    
    if(fileName.isEmpty()) {
        // Empty space - only show Paste
        m_contextMenu->addAction("Paste", "paste", canPaste);
    } else {
        // File/folder - show all options
        m_contextMenu->addAction("Copy", "copy", true);
        m_contextMenu->addAction("Cut", "cut", true);
        m_contextMenu->addAction("Paste", "paste", canPaste);
        m_contextMenu->addSeparator();
        m_contextMenu->addAction("Delete", "delete", true);
    }
    
    m_contextMenu->popup(x, y);
}

bool FilesModel::canPaste() const
{
    const QMimeData *mimeData = QGuiApplication::clipboard()->mimeData();
    return (mimeData && mimeData->hasUrls());
}

QHash<int, QByteArray> FilesModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[NameRole] = "name";
    roles[IconNameRole] = "iconName";
    roles[MimeTypeRole] = "mimeType";
    roles[PathRole] = "path";
    roles[ModifiedDateRole] = "modifiedDate";
    roles[CreatedDateRole] = "createdDate";
    roles[SizeRole] = "size";
    roles[HiddenRole] = "isHidden";
    roles[EmblemNameRole] = "emblemName";

    return roles;
}

int FilesModel::count()
{
    return m_files.length();
}

#include "moc_filesmodel.cpp"
