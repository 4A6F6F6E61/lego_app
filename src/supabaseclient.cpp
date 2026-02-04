#include "supabaseclient.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>

SupabaseClient* SupabaseClient::s_instance = nullptr;

SupabaseClient::SupabaseClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
}

SupabaseClient* SupabaseClient::instance()
{
    if (!s_instance) {
        s_instance = new SupabaseClient();
    }
    return s_instance;
}

void SupabaseClient::initialize(const QString &url, const QString &anonKey)
{
    m_baseUrl = url;
    m_anonKey = anonKey;
}

void SupabaseClient::signIn(const QString &email, const QString &password)
{
    QUrl url(m_baseUrl + "/auth/v1/token?grant_type=password");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    
    QJsonObject json;
    json["email"] = email;
    json["password"] = password;
    
    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleAuthResponse(reply);
    });
}

void SupabaseClient::signUp(const QString &email, const QString &password)
{
    QUrl url(m_baseUrl + "/auth/v1/signup");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    
    QJsonObject json;
    json["email"] = email;
    json["password"] = password;
    
    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleAuthResponse(reply);
    });
}

void SupabaseClient::signOut()
{
    m_accessToken.clear();
    m_userId.clear();
    emit authenticationChanged(false);
}

void SupabaseClient::handleAuthResponse(QNetworkReply *reply)
{
    reply->deleteLater();
    
    if (reply->error() != QNetworkReply::NoError) {
        emit authError(reply->errorString());
        return;
    }
    
    QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
    QJsonObject obj = doc.object();
    
    if (obj.contains("access_token")) {
        m_accessToken = obj["access_token"].toString();
        QJsonObject user = obj["user"].toObject();
        m_userId = user["id"].toString();
        emit authenticationChanged(true);
    } else if (obj.contains("error")) {
        emit authError(obj["error_description"].toString());
    }
}

void SupabaseClient::fetchSets()
{
    if (!isAuthenticated()) {
        emit dataError("Not authenticated");
        return;
    }
    
    QUrl url(m_baseUrl + "/rest/v1/lego_sets");
    QUrlQuery query;
    query.addQueryItem("user_id", "eq." + m_userId);
    query.addQueryItem("select", "*");
    url.setQuery(query);
    
    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_accessToken).toUtf8());
    
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        
        if (reply->error() != QNetworkReply::NoError) {
            emit dataError(reply->errorString());
            return;
        }
        
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        emit setsReceived(doc.array());
    });
}

void SupabaseClient::fetchSetParts(const QString &setId)
{
    if (!isAuthenticated()) {
        emit dataError("Not authenticated");
        return;
    }
    
    QUrl url(m_baseUrl + "/rest/v1/set_parts");
    QUrlQuery query;
    query.addQueryItem("set_id", "eq." + setId);
    query.addQueryItem("select", "*");
    url.setQuery(query);
    
    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_accessToken).toUtf8());
    
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, setId]() {
        reply->deleteLater();
        
        if (reply->error() != QNetworkReply::NoError) {
            emit dataError(reply->errorString());
            return;
        }
        
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        emit partsReceived(setId, doc.array());
    });
}

void SupabaseClient::updateSetStatus(const QString &setId, int status)
{
    if (!isAuthenticated()) {
        emit dataError("Not authenticated");
        return;
    }
    
    QUrl url(m_baseUrl + "/rest/v1/lego_sets");
    QUrlQuery query;
    query.addQueryItem("id", "eq." + setId);
    url.setQuery(query);
    
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_accessToken).toUtf8());
    request.setRawHeader("Prefer", "return=representation");
    
    QJsonObject json;
    json["status"] = status;
    
    QNetworkReply *reply = m_networkManager->sendCustomRequest(request, "PATCH", QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit dataError(reply->errorString());
        }
    });
}

void SupabaseClient::updatePartQuantity(int partId, int quantity)
{
    if (!isAuthenticated()) {
        emit dataError("Not authenticated");
        return;
    }
    
    QUrl url(m_baseUrl + "/rest/v1/set_parts");
    QUrlQuery query;
    query.addQueryItem("id", "eq." + QString::number(partId));
    url.setQuery(query);
    
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_accessToken).toUtf8());
    request.setRawHeader("Prefer", "return=representation");
    
    QJsonObject json;
    json["quantity_found"] = quantity;
    
    QNetworkReply *reply = m_networkManager->sendCustomRequest(request, "PATCH", QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit dataError(reply->errorString());
        }
    });
}
