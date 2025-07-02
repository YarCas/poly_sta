#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "polygonmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<PolygonManager>("PolygonEditor", 1, 0, "PolygonManager");
    qmlRegisterType<Polygon>("PolygonEditor", 1, 0, "Polygon");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("PLM", "Main");

    return app.exec();
}
