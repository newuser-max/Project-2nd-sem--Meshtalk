#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

     // Create the backend — lives for the entire app lifetime
    Backend backend;

    QQmlApplicationEngine engine;

    // Expose backend to QML 
    engine.rootContext()->setContextProperty("backend", &backend);
    qDebug() << "[MAIN] Backend context property set";
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Meshtalk", "Main");

    return QGuiApplication::exec();
}
