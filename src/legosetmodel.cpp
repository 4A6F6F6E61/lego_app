#include "legosetmodel.h"

LegoSetModel::LegoSetModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_supabaseClient(SupabaseClient::instance())
{
    connect(m_supabaseClient, &SupabaseClient::setsReceived,
            this, &LegoSetModel::loadSets);
}

int LegoSetModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_sets.count();
}

QVariant LegoSetModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_sets.count())
        return QVariant();
    
    const LegoSet &set = m_sets.at(index.row());
    
    switch (role) {
    case IdRole:
        return set.id;
    case UserIdRole:
        return set.userId;
    case SetNumRole:
        return set.setNum;
    case NameRole:
        return set.name;
    case YearRole:
        return set.year;
    case ThemeIdRole:
        return set.themeId;
    case ImgUrlRole:
        return set.imgUrl;
    case CreatedAtRole:
        return set.createdAt;
    case StatusRole:
        return set.status;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LegoSetModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[UserIdRole] = "userId";
    roles[SetNumRole] = "setNum";
    roles[NameRole] = "name";
    roles[YearRole] = "year";
    roles[ThemeIdRole] = "themeId";
    roles[ImgUrlRole] = "imgUrl";
    roles[CreatedAtRole] = "createdAt";
    roles[StatusRole] = "status";
    return roles;
}

void LegoSetModel::refresh()
{
    m_supabaseClient->fetchSets();
}

void LegoSetModel::updateStatus(const QString &setId, int status)
{
    m_supabaseClient->updateSetStatus(setId, status);
    
    // Update local model
    for (int i = 0; i < m_sets.count(); ++i) {
        if (m_sets[i].id == setId) {
            m_sets[i].status = status;
            QModelIndex idx = index(i);
            emit dataChanged(idx, idx, {StatusRole});
            break;
        }
    }
}

QVariantList LegoSetModel::getSetsByStatus(int status) const
{
    QVariantList result;
    for (const auto &set : m_sets) {
        if (set.status == status) {
            QVariantMap map;
            map["id"] = set.id;
            map["setNum"] = set.setNum;
            map["name"] = set.name;
            map["year"] = set.year;
            map["imgUrl"] = set.imgUrl;
            map["status"] = set.status;
            result.append(map);
        }
    }
    return result;
}

int LegoSetModel::countByStatus(int status) const
{
    int count = 0;
    for (const auto &set : m_sets) {
        if (set.status == status) {
            count++;
        }
    }
    return count;
}

void LegoSetModel::loadSets(const QJsonArray &setsArray)
{
    beginResetModel();
    m_sets.clear();
    
    for (const auto &value : setsArray) {
        QJsonObject obj = value.toObject();
        LegoSet set;
        set.id = obj["id"].toString();
        set.userId = obj["user_id"].toString();
        set.setNum = obj["set_num"].toString();
        set.name = obj["name"].toString();
        set.year = obj["year"].toInt();
        set.themeId = obj["theme_id"].toInt();
        set.imgUrl = obj["img_url"].toString();
        set.createdAt = obj["created_at"].toString();
        set.status = obj["status"].toInt();
        m_sets.append(set);
    }
    
    endResetModel();
    emit countChanged();
    emit dataChanged();
}
