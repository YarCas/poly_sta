#pragma once
#include <QObject>
#include <QQmlListProperty>
#include <QGeoCoordinate>
#include <QVariantList>
#include <QColor>
class Polygon;
class PolygonManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Polygon> polygons READ polygons NOTIFY polygonsChanged)
    Q_PROPERTY(Polygon* selectedPolygon READ selectedPolygon WRITE setSelectedPolygon NOTIFY selectedPolygonChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    explicit PolygonManager(QObject* parent = nullptr);
    ~PolygonManager() override;
    [[nodiscard]] auto polygons() -> QQmlListProperty<Polygon>;
    [[nodiscard]] auto selectedPolygon() const -> Polygon*;
    auto setSelectedPolygon(Polygon* polygon) -> void;
    [[nodiscard]] auto count() const -> int;
public slots:
    Q_INVOKABLE Polygon* createRectangularPolygon(double centerLat, double centerLon, double widthMeters, double heightMeters);
    Q_INVOKABLE void removePolygon(Polygon* polygon);
    Q_INVOKABLE void removeSelectedPolygon();
    Q_INVOKABLE void clearAll();
signals:
    void polygonsChanged();
    void selectedPolygonChanged();
    void countChanged();
private:
    static auto appendPolygon(QQmlListProperty<Polygon>* list, Polygon* polygon) -> void;
    static auto polygonCount(QQmlListProperty<Polygon>* list) -> qsizetype;
    static auto polygonAt(QQmlListProperty<Polygon>* list, qsizetype index) -> Polygon*;
    static auto clearPolygons(QQmlListProperty<Polygon>* list) -> void;
    QList<Polygon*> m_polygons;
    Polygon* m_selected_polygon;
};
class Polygon : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QVariantList path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged)
    Q_PROPERTY(int borderWidth READ borderWidth WRITE setBorderWidth NOTIFY borderWidthChanged)
    Q_PROPERTY(double area READ area NOTIFY areaChanged)
    Q_PROPERTY(int vertexCount READ vertexCount NOTIFY vertexCountChanged)
    Q_PROPERTY(bool selected READ selected WRITE setSelected NOTIFY selectedChanged)
public:
    explicit Polygon(QObject* parent = nullptr);
    ~Polygon() override;
    [[nodiscard]] auto id() const -> QString;
    auto setId(const QString& id) -> void;
    [[nodiscard]] auto path() const -> QVariantList;
    auto setPath(const QVariantList& path) -> void;
    [[nodiscard]] auto color() const -> QColor;
    auto setColor(const QColor& color) -> void;
    [[nodiscard]] auto borderColor() const -> QColor;
    auto setBorderColor(const QColor& color) -> void;
    [[nodiscard]] auto borderWidth() const -> int;
    auto setBorderWidth(int width) -> void;
    [[nodiscard]] auto area() const -> double;
    [[nodiscard]] auto vertexCount() const -> int;
    [[nodiscard]] auto selected() const -> bool;
    auto setSelected(bool selected) -> void;
public slots:
    Q_INVOKABLE void addVertex(double lat, double lon, int index = -1);
    Q_INVOKABLE void removeVertex(int index);
    Q_INVOKABLE void moveVertex(int index, double lat, double lon);
    Q_INVOKABLE QGeoCoordinate getVertex(int index) const;
signals:
    void idChanged();
    void pathChanged();
    void colorChanged();
    void borderColorChanged();
    void borderWidthChanged();
    void areaChanged();
    void vertexCountChanged();
    void selectedChanged();
private:
    auto calculateArea() -> void;

    QString m_id;
    QVariantList m_path;
    QColor m_color;
    QColor m_border_color;
    int m_border_width;
    double m_area;
    bool m_selected;
};
