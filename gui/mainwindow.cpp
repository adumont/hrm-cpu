#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QTimer>
#include <QTime>
#include <QApplication>
#include <QHeaderView>

#include "Vhrmcpu.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Create our design model with Verilator
    top = new Vhrmcpu;
    top->eval(); // initialize (so PROG gets loaded)

    // Clock Initialization
    clk = true;
    m_timer = new QTimer(this);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(clkTick()));
    //m_timer->start(500);

    // PROG table, set headers
    QStringList LIST;
    for(int i=0; i<256; i++){ LIST.append(QString("%1").arg(i,2,16,QChar('0'))); }
    ui->tblPROG->setVerticalHeaderLabels(LIST);
    ui->tblPROG->setHorizontalHeaderLabels(QStringList("Data"));

    // PROG table, fill with current program
    for(int i=0; i<256; i++){
        ui->tblPROG->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__program0__DOT__rom[i] ,2,16,QChar('0')) ));
    }

    updateUI();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::clkTick()
{
    clk = ! clk;

    top->clk = clk;
    main_time++;

    updateUI();
}

void MainWindow::on_pbA_pressed()
{
    clkTick();
    updateUI();
//    clkTick();
//    updateUI();
}

void MainWindow::on_pbB_toggled(bool checked)
{
    top->cpu_out_rd=checked?1:0;
    updateUI();
}

void MainWindow::updateUI()
{
    top->eval();

    // Clock led
    ui->clk->setState( clk );

    // PC
    ui->PC_PC->setText(QString("%1").arg( top->hrmcpu__DOT__PC0_PC ,2,16,QChar('0')));
    ui->led_PC_branch->setState( top->hrmcpu__DOT__PC0_branch );
    ui->led_PC_ijump->setState( top->hrmcpu__DOT__PC0_ijump );
    ui->led_PC_wPC->setState( top->hrmcpu__DOT__PC0_wPC );
    ui->tblPROG->setCurrentCell(top->hrmcpu__DOT__PC0_PC, 0);

    // PROG
    ui->PROG_ADDR->setText(QString("%1").arg( top->hrmcpu__DOT__PC0_PC ,2,16,QChar('0')));
    ui->PROG_DATA->setText(QString("%1").arg( top->hrmcpu__DOT__program0__DOT__r_data ,2,16,QChar('0')));

    // IR Instruction Register
    ui->IR_INSTR->setText(QString("%1").arg( top->hrmcpu__DOT__IR0_rIR ,2,16,QChar('0')));
    ui->led_IR_wIR->setState( top->hrmcpu__DOT__cu_wIR );

    // Register R
    ui->R_R->setText(QString("%1").arg( top->hrmcpu__DOT__R_value ,2,16,QChar('0')));
    ui->led_R_wR->setState( top->hrmcpu__DOT__cu_wR );

//    ui->lbl_STATE->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__statename ));
//    ui->lbl_INSTR->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__instrname ));

}

