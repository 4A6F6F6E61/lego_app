#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "authmanager.h"
#include "legosetmodel.h"
#include "supabaseclient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    app.setOrganizationName("LegoApp");
    app.setOrganizationDomain("lego-app.example");
    app.setApplicationName("Lego App");
    app.setApplicationVersion("0.1.6");
    
    // Set Material style for Qt Quick Controls
    QQuickStyle::setStyle("Material");
    
    // Initialize Supabase
    SupabaseClient::instance()->initialize(
        "https://kuselrpmvzwtxmfzukxv.supabase.co",
        "sb_publishable_Ymuui0DvLloTR2SO4fVfyw_Bw3MHT87"
    );
    
    QQmlApplicationEngine engine;
    
    // Register QML types
    qmlRegisterSingletonType<AuthManager>("org.lego.app", 1, 0, "AuthManager",
        [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
            Q_UNUSED(engine)
            Q_UNUSED(scriptEngine)
            return AuthManager::instance();
        }
    );
    
    qmlRegisterType<LegoSetModel>("org.lego.app", 1, 0, "LegoSetModel");
    
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);
    
    return app.exec();
}
