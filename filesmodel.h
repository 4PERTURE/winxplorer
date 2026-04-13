#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QDir>
#include <QFileSystemWatcher>
#include <QMediaPlayer>
#include <QThread>
#include <QMimeDatabase>

#include <KF6/KIOCore/kio/global.h>

struct FileDelegate {
    QString name;
    QString iconName;
    QString mimeType;
    QString path;
    QString modifiedDate;
    QString createdDate;
    QString size;
    bool isHidden;
    QString emblemName;
};

class FileFetcherThread : public QThread
{
    Q_OBJECT

public:
    QString getMimeType(const QString &filePath)
    {
        QMimeDatabase mimeDb;
        QMimeType mime = mimeDb.mimeTypeForFile(filePath);
        return mime.comment();
    }

    QString getEmblem(const QFileInfo &file)
    {
        if(!file.isReadable() || !file.isWritable())
            return "emblem-readonly";
        if(file.isSymLink())
            return "emblem-symbolic-link";
        else
            return "";
    }

    QString sdir;
    QDir::SortFlags sortingFlags;
    QDir::Filters filter;

public slots:
    void run() {
        // We need to immediately terminate the thread if
        // the current directory changes before this thread
        // even finished loading the past directory.
        setTerminationEnabled(true);

        QList<QSharedPointer<FileDelegate>> finalFilesList;

        QDir currentDir(sdir);
        currentDir.setSorting(sortingFlags);
        currentDir.setFilter(filter);

        QFileInfoList fileList = currentDir.entryInfoList();

        for(int i = 0; i < fileList.length(); i++) {
            if(fileList[i].fileName() == "." || fileList[i].fileName() == ".." || !fileList[i].exists())
                continue;

            QString absolutePath = fileList[i].absoluteFilePath();

            QSharedPointer<FileDelegate> delegate(new FileDelegate);

            delegate->name = fileList[i].fileName();
            delegate->iconName = KIO::iconNameForUrl(QUrl::fromLocalFile(absolutePath));
            delegate->mimeType = getMimeType(absolutePath);
            delegate->path = absolutePath;
            delegate->modifiedDate = fileList[i].lastModified().toString();
            delegate->createdDate = fileList[i].birthTime().toString();
            delegate->size = fileList[i].isDir() ? "" : QString::number(fileList[i].size()/1024) + " KB";
            delegate->isHidden = fileList[i].isHidden();
            delegate->emblemName = getEmblem(fileList[i]);

            finalFilesList.append(delegate);
        }

        emit loadingFinished(finalFilesList);
    }

signals:
    void loadingFinished(const QList<QSharedPointer<FileDelegate>> filesList);
};

class FilesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY finishRefresh)

    Q_PROPERTY(QString currentDir READ currentDir WRITE setCurrentDir NOTIFY currentDirChanged)
    Q_PROPERTY(QString currentDirIcon READ currentDirIcon NOTIFY currentDirChanged)

    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY beginRefresh)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY beginRefresh)
    Q_PROPERTY(bool canGoUp READ canGoUp NOTIFY beginRefresh)

public:
    explicit FilesModel(QObject *parent = nullptr);
    ~FilesModel();

    enum FileRole {
        NameRole,
        IconNameRole,
        MimeTypeRole,
        PathRole,
        ModifiedDateRole,
        CreatedDateRole,
        SizeRole,
        HiddenRole,
        EmblemNameRole
    };
    Q_ENUM(FileRole)

    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    int count();

    QString currentDir();
    void setCurrentDir(const QString &newDir);

    QString currentDirIcon();

    Q_INVOKABLE void goBack();
    bool canGoBack();

    Q_INVOKABLE void goForward();
    bool canGoForward();

    Q_INVOKABLE void goUp();
    bool canGoUp();

    Q_INVOKABLE QStringList history(const int &type);

    Q_INVOKABLE void trigger(const int &index);
    Q_INVOKABLE void trigger(const QString &path);

    Q_INVOKABLE bool isValidDirectory(const QString &path);

public slots:
    void applyFileList(const QList<QSharedPointer<FileDelegate>> fileList);
    void refreshFileList();

signals:
    Q_INVOKABLE void beginRefresh();
    void finishRefresh();
    void currentDirChanged();

private:
    FileFetcherThread *m_loadingThread = nullptr;

    QList<QSharedPointer<FileDelegate>> m_files;

    QDir *m_currentDir;
    QFileSystemWatcher *m_watcher;

    QMediaPlayer *m_navigationSound;

    bool m_canGoBack;
    bool m_canGoForward;
    bool m_canGoUp;

    QStringList m_history;
    QStringList m_forwardHistory;
    QStringList m_backHistory;
};

#endif // FILESMODEL_H
