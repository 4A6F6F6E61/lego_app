#ifndef LEGOSETMODEL_H
#define LEGOSETMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>
#include "supabaseclient.h"

struct LegoSet {
    QString id;
    QString userId;
    QString setNum;
    QString name;
    int year;
    int themeId;
    QString imgUrl;
    QString createdAt;
    int status; // 0 = backlog, 1 = currently building, 2 = built
};

class LegoSetModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        UserIdRole,
        SetNumRole,
        NameRole,
        YearRole,
        ThemeIdRole,
        ImgUrlRole,
        CreatedAtRole,
        StatusRole
    };
    
    explicit LegoSetModel(QObject *parent = nullptr);
    
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    
    int count() const { return m_sets.count(); }
    
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void updateStatus(const QString &setId, int status);
    Q_INVOKABLE QVariantList getSetsByStatus(int status) const;
    Q_INVOKABLE int countByStatus(int status) const;
    
signals:
    void countChanged();
    void dataChanged();
    
private:
    void loadSets(const QJsonArray &setsArray);
    
    QList<LegoSet> m_sets;
    SupabaseClient *m_supabaseClient;
};

#endif // LEGOSETMODEL_H
