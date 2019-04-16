#include "mainwindow.h"
#include <QApplication>

vluint64_t main_time = 0;
double sc_time_stamp () { return main_time; }

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    return a.exec();
}
