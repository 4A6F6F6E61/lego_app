#ifndef SUPABASECLIENT_H
#define SUPABASECLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class SupabaseClient : public QObject
{
    Q_OBJECT
    
public:
    static SupabaseClient* instance();
    
    void initialize(const QString &url, const QString &anonKey);
    
    void signIn(const QString &email, const QString &password);
    void signUp(const QString &email, const QString &password);
    void signOut();
    
    QString getAccessToken() const { return m_accessToken; }
    QString getUserId() const { return m_userId; }
    bool isAuthenticated() const { return !m_accessToken.isEmpty(); }
    
    // Database queries
    void fetchSets();
    void fetchSetParts(const QString &setId);
    void updateSetStatus(const QString &setId, int status);
    void updatePartQuantity(int partId, int quantity);
    
signals:
    void authenticationChanged(bool authenticated);
    void authError(const QString &error);
    void setsReceived(const QJsonArray &sets);
    void partsReceived(const QString &setId, const QJsonArray &parts);
    void dataError(const QString &error);
    
private:
    explicit SupabaseClient(QObject *parent = nullptr);
    
    void handleAuthResponse(QNetworkReply *reply);
    void handleQueryResponse(QNetworkReply *reply, const QString &operation);
    
    static SupabaseClient *s_instance;
    QNetworkAccessManager *m_networkManager;
    QString m_baseUrl;
    QString m_anonKey;
    QString m_accessToken;
    QString m_userId;
};

#endif // SUPABASECLIENT_H
