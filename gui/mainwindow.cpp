#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QTimer>
#include <QTime>
#include <QApplication>
#include <QHeaderView>
#include <QKeyEvent>

#include "Vhrmcpu.h"
#include "verilated_save.h"
//#include "Vhrmcpu_hrmcpu.h"
//#include "Vhrmcpu_PROG.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Create our design model with Verilator
    top = new Vhrmcpu;
    top->eval(); // initialize (so PROG gets loaded)

    // Verilated::internalsDump();  // See scopes to help debug

    // Clock Initialization
    clk = true;
    m_timer = new QTimer(this);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(clkTick()));
    // m_timer->start( ui->clkPeriod->value() );

    // PROG table, set headers
    QStringList LIST;
    for(int i=0; i<256; i++){ LIST.append(QString("%1").arg(i,2,16,QChar('0'))); }
    ui->tblPROG->setVerticalHeaderLabels(LIST);
    ui->tblPROG->setHorizontalHeaderLabels(QStringList("Data"));

    // PROG table, fill with current program
    for(int i=0; i<256; i++){
        ui->tblPROG->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__program0__DOT__rom[i] ,2,16,QChar('0')) ));
    }


    // RAM table, set headers
    LIST.clear();
    for(int i=0; i<16; i++){ LIST.append(QString("%1").arg(i,1,16,QChar('0'))); }
    ui->tblRAM->setVerticalHeaderLabels(LIST);
    LIST.clear();
    for(int i=0; i<16; i++){ LIST.append(QString("_%1").arg(i,1,16,QChar('0'))); }
    ui->tblRAM->setHorizontalHeaderLabels(LIST);

    // Initialize RAM table
    for(int i=0; i<16; i++){
        for(int j=0; j<16; j++){
            ui->tblRAM->setItem(j,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__MEMORY0__DOT__ram0__DOT__mem[16*j+i] ,2,16,QChar('0')) ));
        }
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

//    if(clk && top->i_rst) {
//        ui->pbReset->released();
//    }

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
    if(checked) {
        ui->pbA->setDisabled(true);
        ui->pbReset->setDisabled(true);
        m_timer->start( ui->clkPeriod->value() );
    } else {
        m_timer->stop();
        ui->pbA->setEnabled(true);
        ui->pbReset->setEnabled(true);
    }
    updateUI();

}

void MainWindow::updateUI()
{
    top->eval();

    // Control Block
    ui->clk->setState( clk );
    ui->led_i_rst->setState(top->i_rst);
    ui->main_time->setText(QString("%1").arg( main_time ));
    ui->led_halt->setState(top->hrmcpu__DOT__cu_halt);

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
    ui->led_R_wR->setState( top->hrmcpu__DOT__register0__DOT__wR );

    // RAM
    ui->MEM_AR->setText( QString("%1").arg( top->hrmcpu__DOT__MEMORY0__DOT__AR_q ,2,16,QChar('0')) );
    ui->MEM_ADDR->setText( QString("%1").arg( top->hrmcpu__DOT__MEMORY0__DOT__ADDR ,2,16,QChar('0')) );
    ui->MEM_DATA->setText( QString("%1").arg( top->hrmcpu__DOT__MEMORY0__DOT__M ,2,16,QChar('0')) );
    ui->led_MEM_srcA->setState( top->hrmcpu__DOT__MEMORY0__DOT__srcA );
    ui->led_MEM_wAR->setState( top->hrmcpu__DOT__MEMORY0__DOT__wAR );
    ui->led_MEM_wM->setState( top->hrmcpu__DOT__MEMORY0__DOT__wM );

    // fill RAM table with current values
    for(int i=0; i<16; i++){
        for(int j=0; j<16; j++){
            ui->tblRAM->item(j,i)->setText(QString("%1").arg( top->hrmcpu__DOT__MEMORY0__DOT__ram0__DOT__mem[16*j+i] ,2,16,QChar('0')));
        }
    }
    ui->tblRAM->setCurrentCell( (int)( top->hrmcpu__DOT__MEMORY0__DOT__AR_q / 16 ), top->hrmcpu__DOT__MEMORY0__DOT__AR_q % 16 );

    //    ui->lbl_STATE->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__statename ));
    //    ui->lbl_INSTR->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__instrname ));

}


void MainWindow::on_clkPeriod_valueChanged(int period)
{
    m_timer->setInterval(period);
}

void MainWindow::keyPressEvent(QKeyEvent *e)
{
    if(e->key() == Qt::Key_F5) {
        ui->pbB->toggle();
    }
}

void MainWindow::on_pbReset_toggled(bool checked)
{
    top->i_rst=checked;
    updateUI();
}

void MainWindow::on_pbRcommit_pressed()
{
    top->hrmcpu__DOT__register0__DOT__R=1;
    top->hrmcpu__DOT__cu_wR=true;
    ui->lineEdit->setText("Hola");
    updateUI();
}

void MainWindow::on_pbSave_pressed()
{
    VerilatedSave os;
//    os.open(filenamep);
//    os << main_time;  // user code must save the timestamp, etc
//    os << *topp;
}
