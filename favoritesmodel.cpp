#include "favoritesmodel.h"

#include <QStandardPaths>

#include <KF6/KIOCore/kio/global.h>

FavoritesModel::FavoritesModel(QObject *parent)
    : QAbstractListModel{parent}
{
    m_watcher = new QFileSystemWatcher();
    // TODO: make this refresh a single entry instead of the whole list
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &FavoritesModel::refreshLinksList);
    connect(m_watcher, &QFileSystemWatcher::directoryChanged, this, &FavoritesModel::refreshLinksList);

    m_linksDir = new QDir(QDir::homePath());

    if(!m_linksDir->exists("Links/"))
        m_linksDir->mkdir("Links");

    m_linksDir->cd("Links");

    m_watcher->addPath(m_linksDir->absolutePath());

    refreshLinksList();
}

FavoritesModel::~FavoritesModel()
{}

int FavoritesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_links.length();
}

QVariant FavoritesModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() && index.row() < 0 && index.row() > m_links.length())
        return 0;

    QSharedPointer<LinkDelegate> delegate = m_links.at(index.row());

    switch((FavoriteRole) role) {
    case NameRole:
        return delegate->name;
    case IconNameRole:
        return delegate->iconName;
    case PathRole:
        return delegate->path;
    }

    return QVariant();
}

QHash<int, QByteArray> FavoritesModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[NameRole] = "name";
    roles[IconNameRole] = "iconName";
    roles[PathRole] = "path";

    return roles;
}

int FavoritesModel::count()
{
    return m_links.length();
}

void FavoritesModel::refreshLinksList()
{
    beginResetModel();
    m_links.clear();
    endResetModel();

    m_linksThread = new LinksFetcherThread();
    m_linksThread->sdir = m_linksDir->absolutePath();

    QObject::connect(m_linksThread, &LinksFetcherThread::fetchingFinished, this, &FavoritesModel::applyLinksList);

    m_linksThread->start();
}

// these 2 functions haven't been tested yet
void FavoritesModel::addItem(const QString &path)
{
    QFile file(path);
    file.link(m_linksDir->absolutePath() + "/" + file.fileName());
}
void FavoritesModel::removeItem(const int &index)
{
    beginRemoveRows(QModelIndex(), index, index);
    m_linksDir->remove(m_links.at(index)->name);
    endRemoveRows();
}


void FavoritesModel::trigger(const QString &path)
{
    m_filesModel->trigger(path);
}

FilesModel *FavoritesModel::filesModel()
{
    return m_filesModel;
}

void FavoritesModel::setFilesModel(FilesModel *filesModel)
{
    m_filesModel = filesModel;
    emit filesModelChanged();
}

void FavoritesModel::applyLinksList(const QList<QSharedPointer<LinkDelegate>> linksList)
{
    beginInsertRows(QModelIndex(), 0, linksList.length()-1);
    for(int i = 0; i < linksList.length(); i++) {
        QSharedPointer<LinkDelegate> delegate = linksList[i];

        m_links.append(delegate);
    }
    endInsertRows();
    emit countChanged();
}
