#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include "supabaseclient.h"

class AuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authenticationChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    
public:
    static AuthManager* instance();
    
    bool isAuthenticated() const;
    QString errorMessage() const { return m_errorMessage; }
    
    Q_INVOKABLE void login(const QString &email, const QString &password);
    Q_INVOKABLE void registerUser(const QString &email, const QString &password);
    Q_INVOKABLE void logout();
    
signals:
    void authenticationChanged();
    void errorMessageChanged();
    void loginSuccessful();
    void registrationSuccessful();
    
private:
    explicit AuthManager(QObject *parent = nullptr);
    
    void setErrorMessage(const QString &message);
    
    static AuthManager *s_instance;
    SupabaseClient *m_supabaseClient;
    QString m_errorMessage;
};

#endif // AUTHMANAGER_H
