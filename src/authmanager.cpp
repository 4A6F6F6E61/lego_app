#include "authmanager.h"

AuthManager* AuthManager::s_instance = nullptr;

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
    , m_supabaseClient(SupabaseClient::instance())
{
    connect(m_supabaseClient, &SupabaseClient::authenticationChanged,
            this, &AuthManager::authenticationChanged);
    connect(m_supabaseClient, &SupabaseClient::authError,
            this, &AuthManager::setErrorMessage);
}

AuthManager* AuthManager::instance()
{
    if (!s_instance) {
        s_instance = new AuthManager();
    }
    return s_instance;
}

bool AuthManager::isAuthenticated() const
{
    return m_supabaseClient->isAuthenticated();
}

void AuthManager::login(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        setErrorMessage("Please enter both email and password");
        return;
    }
    
    m_supabaseClient->signIn(email, password);
    
    // Connect to authentication changed to emit loginSuccessful
    connect(m_supabaseClient, &SupabaseClient::authenticationChanged,
            this, [this](bool authenticated) {
        if (authenticated) {
            emit loginSuccessful();
        }
    });
}

void AuthManager::registerUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        setErrorMessage("Please enter both email and password");
        return;
    }
    
    m_supabaseClient->signUp(email, password);
    
    // Connect to authentication changed to emit registrationSuccessful
    connect(m_supabaseClient, &SupabaseClient::authenticationChanged,
            this, [this](bool authenticated) {
        if (authenticated) {
            emit registrationSuccessful();
        }
    });
}

void AuthManager::logout()
{
    m_supabaseClient->signOut();
}

void AuthManager::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}
