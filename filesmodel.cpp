#include "filesmodel.h"

#include <QMimeDatabase>
#include <QDir>
#include <QDesktopServices>
#include <QUrl>

#include <KF6/KIOCore/kio/global.h>

FilesModel::FilesModel(QObject *parent)
    : QAbstractListModel{parent}
{
    connect(this, &FilesModel::refresh, this, &FilesModel::getFiles);
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

    FilesDelegate* delegate = m_files[index.row()];

    switch((FileRole) role) {
    case NameRole:
        return delegate->name();
    case IconNameRole:
        return delegate->iconName();
    case MimeTypeRole:
        return delegate->mimeType();
    case PathRole:
        return delegate->path();
    case ModifiedRole:
        return delegate->modifiedDate();
    case SizeRole:
        return delegate->size();
    case HiddenRole:
        return delegate->isHidden();
    }

    return QVariant();
}

QString FilesModel::currentDir()
{
    return m_currentDir;
}

QString FilesModel::getMimeType(const QString &filePath)
{
    QMimeDatabase mimeDb;
    QMimeType mime = mimeDb.mimeTypeForFile(filePath);
    return mime.name();
}

void FilesModel::setCurrentDir(const QString &newDir)
{
    m_canGoBack = m_backHistory.length() > 0;
    m_canGoForward = m_forwardHistory.length() > 0;

    m_currentDir = newDir;
    m_canGoUp = m_currentDir != "/";
    emit refresh();
}

QString FilesModel::currentDirIcon()
{
    return m_currentDirIcon;
}

void FilesModel::goBack()
{
    if(m_canGoBack) {
        const QString previousDir = m_currentDir;
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
        const QString previousDir = m_currentDir;
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
        QDir currentDir(m_currentDir);

        m_backHistory.clear();
        m_forwardHistory.append(currentDir.absolutePath());

        m_canGoBack = m_backHistory.length() > 0;
        m_canGoForward = m_forwardHistory.length() > 0;

        currentDir.cdUp();
        setCurrentDir(currentDir.absolutePath());

        m_canGoUp = m_currentDir != "/";
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

void FilesModel::getFiles()
{
    beginResetModel();
    m_files.clear();
    endResetModel();

    QDir directory(m_currentDir);

    m_currentDirIcon = KIO::iconNameForUrl(QUrl::fromLocalFile(directory.absolutePath()));

    directory.setSorting(QDir::DirsFirst | QDir::Name | QDir::IgnoreCase | QDir::LocaleAware);
    directory.setFilter(QDir::AllEntries | QDir::Hidden);
    QList<QFileInfo> fileList = directory.entryInfoList();

    beginInsertRows(QModelIndex(), 0, fileList.length()-3);
    for(int i = 0; i < fileList.length(); i++) {
        if(fileList[i].fileName() == "." || fileList[i].fileName() == "..") {
            fileList.removeAt(i);
            i = 0;
        }
        else {
            FilesDelegate * delegate = new FilesDelegate();

            delegate->setName(fileList[i].fileName());
            delegate->setIconName(KIO::iconNameForUrl(QUrl::fromLocalFile(fileList[i].absoluteFilePath())));
            delegate->setMimeType(getMimeType(fileList[i].absoluteFilePath()));
            delegate->setPath(fileList[i].absoluteFilePath());
            delegate->setModifiedDate(fileList[i].lastModified().toString());
            delegate->setSize(fileList[i].isDir() ? "" : QString::number(fileList[i].size()/1024) + " KB");
            delegate->setHidden(fileList[i].isHidden());

            m_files.append(delegate);
        }
    }
    endInsertRows();
}

void FilesModel::trigger(const int &index)
{
    if(index < 0 && index > m_files.length())
        return;

    QFileInfo file(m_files.at(index)->path());

    if(file.isDir()) {
        if(m_forwardHistory.length() > 0) {
            if(file.absoluteFilePath() != m_forwardHistory.at(0)) {
                m_forwardHistory.clear();
                m_canGoForward = m_forwardHistory.length() > 0;
            }
        }

        m_backHistory.append(file.absolutePath());

        setCurrentDir(file.absoluteFilePath());
    }
    else
        QDesktopServices::openUrl(QUrl::fromLocalFile(file.absoluteFilePath()));
}

QHash<int, QByteArray> FilesModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[NameRole] = "name";
    roles[IconNameRole] = "iconName";
    roles[MimeTypeRole] = "mimeType";
    roles[PathRole] = "path";
    roles[ModifiedRole] = "modifiedDate";
    roles[SizeRole] = "size";
    roles[HiddenRole] = "isHidden";

    return roles;
}

#include "moc_filesmodel.cpp"
