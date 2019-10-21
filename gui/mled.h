#ifndef MLED_H
#define MLED_H

#include <QObject>
#include <QPixmap>
#include <QLabel>

class MLed : public QLabel
{
    Q_OBJECT

public:
    //MLed();
    explicit MLed(QWidget* parent = Q_NULLPTR, Qt::WindowFlags f = Qt::WindowFlags());
    void setColor(int);
    void setOn();
    void setOff();
    void setState(bool);
    bool getState();

private slots:
    void toggleState();

signals:
    void clicked();

protected:
    void mouseDoubleClickEvent(QMouseEvent* event);

private:
    int m_color;  // 0: green, 1: red, 2: blue, 3: yellow
    bool m_state; // 0: off, 1: on
    bool clickable;
    QPixmap pmOn;
    QPixmap pmOff;
};

#endif // MLED_H
