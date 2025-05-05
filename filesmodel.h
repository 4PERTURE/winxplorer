#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QObject>
#include <QAbstractListModel>

class FilesDelegate : public QObject
{
    Q_OBJECT

public:
    explicit FilesDelegate() {}

    QString name() { return m_name; }
    void setName(const QString &newName) { m_name = newName; }

    QString iconName() { return m_iconName; }
    void setIconName(const QString &newIcon) { m_iconName = newIcon; }

    QString mimeType() { return m_mimeType; }
    void setMimeType(const QString &newMimeType) { m_mimeType = newMimeType; }

    QString path() { return m_path; }
    void setPath(const QString &newPath) { m_path = newPath; }

    QString modifiedDate() { return m_modifiedDate; }
    void setModifiedDate(const QString &newDate) { m_modifiedDate = newDate; }

    QString size() { return m_size; }
    void setSize(const QString &newSize) { m_size = newSize; }

    bool isHidden() { return m_isHidden; }
    void setHidden(const bool &isHidden) { m_isHidden = isHidden; }

private:
    QString m_name;
    QString m_iconName;
    QString m_mimeType;
    QString m_path;
    QString m_modifiedDate;
    QString m_size;
    bool m_isHidden;

};

class FilesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString currentDir READ currentDir WRITE setCurrentDir NOTIFY refresh)
    Q_PROPERTY(QString currentDirIcon READ currentDirIcon NOTIFY refresh)

    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY refresh)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY refresh)
    Q_PROPERTY(bool canGoUp READ canGoUp NOTIFY refresh)

public:
    explicit FilesModel(QObject *parent = nullptr);

    enum FileRole {
        NameRole,
        IconNameRole,
        MimeTypeRole,
        PathRole,
        ModifiedRole,
        SizeRole,
        HiddenRole
    };

    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

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

    QString getMimeType(const QString &filePath);
    void getFiles();

    Q_INVOKABLE void trigger(const int &index);

signals:
    Q_INVOKABLE void refresh();

private:
    QList<FilesDelegate*> m_files;

    QString m_currentDir;
    QString m_currentDirIcon;

    bool m_canGoBack;
    bool m_canGoForward;
    bool m_canGoUp;

    QStringList m_history;
    QStringList m_forwardHistory;
    QStringList m_backHistory;
};

#endif // FILESMODEL_H
