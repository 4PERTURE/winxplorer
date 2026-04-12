#include <QApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlExtensionPlugin>

#include <KF6/KWindowSystem/kwindoweffects.h>

#include "filesmodel.h"
#include "favoritesmodel.h"


Q_IMPORT_QML_PLUGIN(ControlsPlugin)
Q_IMPORT_QML_PLUGIN(PanesPlugin)

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<FilesModel>("io.gitgud.catpswin56.private.filesbackend", 1, 0, "FilesModel");
    qmlRegisterType<FavoritesModel>("io.gitgud.catpswin56.private.filesbackend", 1, 0, "FavoritesModel");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("appwinxplorer", "Main");

    for(int i = 0; i < engine.rootObjects().count(); i++) {
        QObject *object = engine.rootObjects().at(i);
        if (object->inherits("QQuickWindow")) {
            KWindowEffects::enableBlurBehind(qobject_cast<QQuickWindow*>(object), true, QRegion(0,0, 0, 0));
            break;
        }
    }

    app.setWindowIcon(QIcon::fromTheme("system-file-manager"));

    return app.exec();
}
