#include "polygonmanager.h"
#include <QGeoCoordinate>
#include <QUuid>
#include <QtMath>
#include <QDebug>
PolygonManager::PolygonManager(QObject* parent)
    : QObject(parent)
    , m_selected_polygon(nullptr)
{
    qDebug() << "PolygonManager: Initializing polygon manager";
    createRectangularPolygon(59.9311, 30.3609, 2000, 1500);
    qDebug() << "PolygonManager: Created test polygon at Saint Petersburg coordinates";
}
PolygonManager::~PolygonManager()
{
    qDeleteAll(m_polygons);
}
auto PolygonManager::polygons() -> QQmlListProperty<Polygon>
{
    return QQmlListProperty<Polygon>(this, nullptr, &PolygonManager::appendPolygon,
                                     &PolygonManager::polygonCount, &PolygonManager::polygonAt,
                                     &PolygonManager::clearPolygons);
}
auto PolygonManager::selectedPolygon() const -> Polygon*
{
    return m_selected_polygon;
}
auto PolygonManager::setSelectedPolygon(Polygon* polygon) -> void
{
    if (m_selected_polygon == polygon)
        return;
    if (m_selected_polygon) {
        m_selected_polygon->setSelected(false);
    }
    m_selected_polygon = polygon;
    if (m_selected_polygon) {
        m_selected_polygon->setSelected(true);
    }
    emit selectedPolygonChanged();
}
auto PolygonManager::count() const -> int
{
    return m_polygons.size();
}
Polygon* PolygonManager::createRectangularPolygon(double centerLat, double centerLon, double widthMeters, double heightMeters)
{
    qDebug() << "PolygonManager: Creating rectangular polygon at" << centerLat << "," << centerLon 
             << "with size" << widthMeters << "x" << heightMeters;
    
    if (!validatePolygonParameters(centerLat, centerLon, widthMeters, heightMeters)) {
        qDebug() << "PolygonManager: Invalid polygon parameters";
        emit errorOccurred("Недопустимые параметры полигона");
        return nullptr;
    }

    auto* polygon = new Polygon(this);
    QString polygonId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    polygon->setId(polygonId);
    polygon->setColor(QColor(255, 0, 0, 100));
    polygon->setBorderColor(QColor(255, 0, 0, 255));
    polygon->setBorderWidth(2);
    
    qDebug() << "PolygonManager: Created polygon with ID:" << polygonId;

    auto const earth_radius = 6371000.0;
    auto const lat_offset = (heightMeters / 2.0) / earth_radius * (180.0 / M_PI);
    auto const lon_offset = (widthMeters / 2.0) / (earth_radius * qCos(centerLat * M_PI / 180.0)) * (180.0 / M_PI);
    
    qDebug() << "PolygonManager: Calculated offsets - lat:" << lat_offset << "lon:" << lon_offset;

    QGeoCoordinate coord1(centerLat - lat_offset, centerLon - lon_offset);
    QGeoCoordinate coord2(centerLat - lat_offset, centerLon + lon_offset);
    QGeoCoordinate coord3(centerLat + lat_offset, centerLon + lon_offset);
    QGeoCoordinate coord4(centerLat + lat_offset, centerLon - lon_offset);
    
    QVariantList path;
    path.append(QVariant::fromValue(coord1));
    path.append(QVariant::fromValue(coord2));
    path.append(QVariant::fromValue(coord3));
    path.append(QVariant::fromValue(coord4));
    
    qDebug() << "PolygonManager: Created path with coordinates:";
    qDebug() << "  " << coord1.latitude() << "," << coord1.longitude();
    qDebug() << "  " << coord2.latitude() << "," << coord2.longitude();
    qDebug() << "  " << coord3.latitude() << "," << coord3.longitude();
    qDebug() << "  " << coord4.latitude() << "," << coord4.longitude();

    polygon->setPath(path);
    
    qDebug() << "PolygonManager: Polygon area calculated:" << polygon->area() << "m²";

    m_polygons.append(polygon);
    qDebug() << "PolygonManager: Added polygon to list, total count:" << m_polygons.size();
    
    emit polygonsChanged();
    emit countChanged();
    setSelectedPolygon(polygon);
    return polygon;
}
auto PolygonManager::removePolygon(Polygon* polygon) -> void
{
    if (!polygon || !m_polygons.contains(polygon))
        return;
    if (m_selected_polygon == polygon) {
        setSelectedPolygon(nullptr);
    }
    m_polygons.removeOne(polygon);
    polygon->deleteLater();
    emit polygonsChanged();
    emit countChanged();
}
auto PolygonManager::removeSelectedPolygon() -> void
{
    if (m_selected_polygon) {
        removePolygon(m_selected_polygon);
    }
}
auto PolygonManager::clearAll() -> void
{
    setSelectedPolygon(nullptr);
    qDeleteAll(m_polygons);
    m_polygons.clear();
    emit polygonsChanged();
    emit countChanged();
}

bool PolygonManager::validatePolygonParameters(double centerLat, double centerLon, double widthMeters, double heightMeters) const
{
    if (centerLat < -90.0 || centerLat > 90.0) {
        return false;
    }
    if (centerLon < -180.0 || centerLon > 180.0) {
        return false;
    }
    if (widthMeters <= 0.0 || heightMeters <= 0.0) {
        return false;
    }
    if (widthMeters > 40075000.0 || heightMeters > 20003000.0) {
        return false;
    }
    return true;
}
auto PolygonManager::appendPolygon(QQmlListProperty<Polygon>* list, Polygon* polygon) -> void
{
    auto* manager = qobject_cast<PolygonManager*>(list->object);
    if (manager && polygon) {
        manager->m_polygons.append(polygon);
    }
}
auto PolygonManager::polygonCount(QQmlListProperty<Polygon>* list) -> qsizetype
{
    auto* manager = qobject_cast<PolygonManager*>(list->object);
    return manager ? manager->m_polygons.count() : 0;
}
auto PolygonManager::polygonAt(QQmlListProperty<Polygon>* list, qsizetype index) -> Polygon*
{
    auto* manager = qobject_cast<PolygonManager*>(list->object);
    return (manager && index >= 0 && index < manager->m_polygons.count()) ? manager->m_polygons.at(index) : nullptr;
}
auto PolygonManager::clearPolygons(QQmlListProperty<Polygon>* list) -> void
{
    auto* manager = qobject_cast<PolygonManager*>(list->object);
    if (manager) {
        qDeleteAll(manager->m_polygons);
        manager->m_polygons.clear();
    }
}
Polygon::Polygon(QObject* parent)
    : QObject(parent)
    , m_color(Qt::red)
    , m_border_color(Qt::darkRed)
    , m_border_width(2)
    , m_area(0.0)
    , m_selected(false)
{
}
Polygon::~Polygon() = default;
auto Polygon::id() const -> QString
{
    return m_id;
}
auto Polygon::setId(const QString& id) -> void
{
    if (m_id == id)
        return;
    m_id = id;
    emit idChanged();
}
auto Polygon::path() const -> QVariantList
{
    return m_path;
}
auto Polygon::setPath(const QVariantList& path) -> void
{
    if (m_path == path)
        return;
    m_path = path;
    calculateArea();
    emit pathChanged();
    emit areaChanged();
    emit vertexCountChanged();
}
auto Polygon::color() const -> QColor
{
    return m_color;
}
auto Polygon::setColor(const QColor& color) -> void
{
    if (m_color == color)
        return;
    m_color = color;
    emit colorChanged();
}
auto Polygon::borderColor() const -> QColor
{
    return m_border_color;
}
auto Polygon::setBorderColor(const QColor& color) -> void
{
    if (m_border_color == color)
        return;
    m_border_color = color;
    emit borderColorChanged();
}
auto Polygon::borderWidth() const -> int
{
    return m_border_width;
}
auto Polygon::setBorderWidth(int width) -> void
{
    if (m_border_width == width)
        return;
    m_border_width = width;
    emit borderWidthChanged();
}
auto Polygon::area() const -> double
{
    return m_area;
}
auto Polygon::vertexCount() const -> int
{
    return m_path.size();
}
auto Polygon::selected() const -> bool
{
    return m_selected;
}
auto Polygon::setSelected(bool selected) -> void
{
    if (m_selected == selected)
        return;
    m_selected = selected;
    emit selectedChanged();
}
bool Polygon::addVertex(double lat, double lon, int index)
{
    if (!validateCoordinate(lat, lon)) {
        emit validationError("Недопустимые координаты вершины");
        return false;
    }

    if (m_path.size() >= 50) {
        emit validationError("Превышено максимальное количество вершин (50)");
        return false;
    }

    QGeoCoordinate coord(lat, lon);
    QVariant coord_variant = QVariant::fromValue(coord);
    if (index < 0 || index >= m_path.size()) {
        m_path.append(coord_variant);
    } else {
        m_path.insert(index, coord_variant);
    }
    calculateArea();
    emit pathChanged();
    emit areaChanged();
    emit vertexCountChanged();
    return true;
}
bool Polygon::removeVertex(int index)
{
    if (index < 0 || index >= m_path.size()) {
        emit validationError("Недопустимый индекс вершины");
        return false;
    }

    if (m_path.size() <= 3) {
        emit validationError("Нельзя удалить вершину: минимум 3 вершины");
        return false;
    }

    m_path.removeAt(index);
    calculateArea();
    emit pathChanged();
    emit areaChanged();
    emit vertexCountChanged();
    return true;
}
bool Polygon::moveVertex(int index, double lat, double lon)
{
    if (index < 0 || index >= m_path.size()) {
        emit validationError("Недопустимый индекс вершины");
        return false;
    }

    if (!validateCoordinate(lat, lon)) {
        emit validationError("Недопустимые координаты вершины");
        return false;
    }

    QGeoCoordinate coord(lat, lon);
    m_path[index] = QVariant::fromValue(coord);
    calculateArea();
    emit pathChanged();
    emit areaChanged();
    return true;
}
QGeoCoordinate Polygon::getVertex(int index) const
{
    if (index >= 0 && index < m_path.size()) {
        return m_path[index].value<QGeoCoordinate>();
    }
    return QGeoCoordinate();
}
bool Polygon::validateCoordinate(double lat, double lon) const
{
    return (lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0);
}

auto Polygon::calculateArea() -> void
{
    if (m_path.size() < 3) {
        m_area = 0.0;
        return;
    }
    double area = 0.0;
    auto const earth_radius = 6371000.0;
    for (int i = 0; i < m_path.size(); ++i) {
        auto const current = m_path[i].value<QGeoCoordinate>();
        auto const next = m_path[(i + 1) % m_path.size()].value<QGeoCoordinate>();
        auto const lat1 = current.latitude() * M_PI / 180.0;
        auto const lat2 = next.latitude() * M_PI / 180.0;
        auto const delta_lon = (next.longitude() - current.longitude()) * M_PI / 180.0;
        area += delta_lon * (2.0 + qSin(lat1) + qSin(lat2));
    }
    area = qAbs(area) * earth_radius * earth_radius / 2.0;
    m_area = area;
}
