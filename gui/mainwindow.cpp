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

    // INBOX table
    for(int i=0; i<32; i++){
        ui->tblINBOX->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__INBOX__DOT__fifo[i] ,2,16,QChar('0')) ));
    }

    // OUTBOX table
    for(int i=0; i<32; i++){
        ui->tblOUTBOX->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__OUTB__DOT__fifo[i] ,2,16,QChar('0')) ));
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

    ttr_pbPUSH = 0;

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
}

void MainWindow::on_pbB_toggled(bool checked)
{
    if(checked) {
        ui->pbA->setDisabled(true);
//        ui->pbReset->setDisabled(true);
        m_timer->start( ui->clkPeriod->value() );
    } else {
        m_timer->stop();
        ui->pbA->setEnabled(true);
//        ui->pbReset->setEnabled(true);
    }
}

void MainWindow::updateUI()
{
    bool toUintSuccess;

    // update INPUTS before we EVAL()
    top->cpu_in_wr = ui->pbPUSH->isChecked();

//    int x;
//    std::stringstream ss;
//    ss << std::hex << ui->editINdata->text();
//    ss >> top->cpu_in_data;

    top->cpu_in_data = ui->editINdata->text().toUInt(&toUintSuccess,16);; //ui->editINdata->text().toInt();

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

    // udpate INBOX leds and Labels
    ui->led_INBOX_empty->setState( ! top->hrmcpu__DOT__INBOX_empty_n );
    ui->led_INBOX_full->setState( top->hrmcpu__DOT__INBOX_full );
    ui->led_INBOX_rd->setState( top->hrmcpu__DOT__INBOX_i_rd );
    ui->INBOX_data->setText( QString("%1").arg( top->hrmcpu__DOT__INBOX_o_data ,2,16,QChar('0')) );

    // udpate INBOX table
    for(int i=0; i<32; i++){
        ui->tblINBOX->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__INBOX__DOT__fifo[i] ,2,16,QChar('0')) ));
    }

    // OUTBOX table
    for(int i=0; i<32; i++){
        ui->tblOUTBOX->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__OUTB__DOT__fifo[i] ,2,16,QChar('0')) ));
    }

    //    ui->lbl_STATE->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__statename ));
    //    ui->lbl_INSTR->setText(QString( top->hrmcpu__DOT__ControlUnit0__DOT__instrname ));

    if( main_time>=ttr_pbPUSH && ui->pbPUSH->isChecked() ) {
        ui->pbPUSH->setChecked(false); // release
    }
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

void MainWindow::on_pbSave_pressed()
{
    VerilatedSave os;
//    os.open(filenamep);
//    os << main_time;  // user code must save the timestamp, etc
//    os << *topp;
}

void MainWindow::on_pbPUSH_toggled(bool checked)
{
    top->cpu_in_wr = checked;
    /* if(checked) */ ttr_pbPUSH = main_time+2; // release in 2 ticks
}

void MainWindow::on_pbPOP_toggled(bool checked)
{
    top->cpu_out_rd = checked;
    ttr_pbPOP = main_time+2;
}
