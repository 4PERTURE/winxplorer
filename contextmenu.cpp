#include "contextmenu.h"
#include <QApplication>
#include <QScreen>

ContextMenu::ContextMenu(QObject *parent)
    : QObject(parent), m_menu(new QMenu())
{
}

ContextMenu::~ContextMenu()
{
    delete m_menu;
}

void ContextMenu::addAction(const QString &text, const QString &actionName, bool enabled)
{
    QAction *action = m_menu->addAction(text);
    action->setEnabled(enabled);
    connect(action, &QAction::triggered, this, [this, actionName]() {
        emit triggered(actionName);
    });
}

void ContextMenu::addSeparator()
{
    m_menu->addSeparator();
}

void ContextMenu::clear()
{
    m_menu->clear();
}

void ContextMenu::popup(int x, int y)
{
    QScreen *screen = QApplication::primaryScreen();
    if(screen) {
        m_menu->popup(QPoint(x, y));
    }
}
