#ifndef FAVORITESMODEL_H
#define FAVORITESMODEL_H

#include "filesmodel.h"

#include <QDir>
#include <QAbstractListModel>

class FilesModel;

struct LinkDelegate {
    QString name;
    QString iconName;
    QString path;
};

class LinksFetcherThread : public QThread
{
    Q_OBJECT

public:
    QString sdir;

public slots:
    void run() {
        QList<QSharedPointer<LinkDelegate>> finalLinksList;

        QDir currentDir(sdir);
        currentDir.setSorting(QDir::Unsorted);

        QFileInfoList fileList = currentDir.entryInfoList();

        for(int i = 0; i < fileList.length(); i++) {
            if(fileList[i].fileName() == "." || fileList[i].fileName() == ".." || !fileList[i].exists())
                continue;

            QSharedPointer<LinkDelegate> delegate(new LinkDelegate);

            delegate->name = fileList[i].fileName();

            delegate->iconName = KIO::iconNameForUrl(
                QUrl::fromLocalFile(fileList[i].isSymLink() ? fileList[i].canonicalFilePath() : fileList[i].absoluteFilePath()));

            delegate->path = fileList[i].absoluteFilePath();;

            finalLinksList.append(delegate);
        }

        emit fetchingFinished(finalLinksList);
    }

signals:
    void fetchingFinished(const QList<QSharedPointer<LinkDelegate>> linksList);
};

class FavoritesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_PROPERTY(FilesModel *filesModel READ filesModel WRITE setFilesModel NOTIFY filesModelChanged)

public:
    explicit FavoritesModel(QObject *parent = nullptr);
    ~FavoritesModel();

    enum FavoriteRole {
        NameRole,
        IconNameRole,
        PathRole
    };
    Q_ENUM(FavoriteRole)

    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    int count();

    void refreshLinksList();

    Q_INVOKABLE void addItem(const QString &path);
    Q_INVOKABLE void removeItem(const int &index);

    Q_INVOKABLE void trigger(const QString &path);

    FilesModel *filesModel();
    void setFilesModel(FilesModel *filesModel);

public slots:
    void applyLinksList(const QList<QSharedPointer<LinkDelegate>> linksList);

signals:
    void filesModelChanged();
    void countChanged();

private:
    LinksFetcherThread *m_linksThread = nullptr;

    FilesModel *m_filesModel;

    QFileSystemWatcher *m_watcher;
    QDir *m_linksDir;
    QList<QSharedPointer<LinkDelegate>> m_links;
};

#endif // FAVORITESMODEL_H
