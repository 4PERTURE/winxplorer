#ifndef CONTEXTMENU_H
#define CONTEXTMENU_H

#include <QObject>
#include <QMenu>
#include <QQmlEngine>

class ContextMenu : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ContextMenu(QObject *parent = nullptr);
    ~ContextMenu();

    Q_INVOKABLE void addAction(const QString &text, const QString &actionName, bool enabled = true);
    Q_INVOKABLE void addSeparator();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void popup(int x, int y);

signals:
    void triggered(const QString &actionName);

private:
    QMenu *m_menu;
};

#endif // CONTEXTMENU_H
