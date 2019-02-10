#include "mled.h"

//MLed::MLed(){}

MLed::MLed(QWidget* parent, Qt::WindowFlags f)
    : QLabel(parent) {
    this->setColor(1);
    this->setOff();
}

//MLed::~MLed()
//{

//}

/*
    void setColor(int);
    void setOn();
    void setOff();
    void setState(bool);
*/

void MLed::setColor( int color )
{   // 0: green, 1: red, 2: blue, 3: yellow
    if(color<4){
        m_color = color;
    } else {
        m_color = 1;
    }

    switch(m_color) {
        case 0 :
            pmOn = QPixmap(":/assets/leds/assets/leds/green.svg");
            pmOff = QPixmap(":/assets/leds/assets/leds/green_off.svg");
            break;
        case 1 :
            pmOn = QPixmap(":/assets/leds/assets/leds/red.svg");
            pmOff = QPixmap(":/assets/leds/assets/leds/red_off.svg");
            break;
        case 2 :
            pmOn = QPixmap(":/assets/leds/assets/leds/blue.svg");
            pmOff = QPixmap(":/assets/leds/assets/leds/blue_off.svg");
            break;
        case 3 :
            pmOn = QPixmap(":/assets/leds/assets/leds/yellow.svg");
            pmOff = QPixmap(":/assets/leds/assets/leds/yellow_off.svg");
            break;
    }
}

void MLed::setState(bool state)
{
    m_state = state;
    this->setPixmap( state ? pmOn : pmOff );
}

void MLed::setOn()
{
    setState(true);
}

void MLed::setOff()
{
    setState(false);
}
