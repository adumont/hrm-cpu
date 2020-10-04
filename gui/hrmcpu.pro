#-------------------------------------------------
#
# Project created by QtCreator 2019-01-13T15:09:30
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = hrmcpu
TEMPLATE = app

INCLUDEPATH += ../verilog/obj_dir
INCLUDEPATH += $(HOME)/toolchain/share/verilator/include
#INCLUDEPATH += $(HOME)/toolchain/share/verilator/include/vltstd

CONFIG += c++11

LIBS += ../verilog/obj_dir/*.o

SOURCES += main.cpp\
        mainwindow.cpp \
    mled.cpp

HEADERS  += mainwindow.h \
    mled.h

FORMS    += mainwindow.ui

RESOURCES += \
    assets.qrc
