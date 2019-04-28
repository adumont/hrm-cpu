#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QTimer>
#include <QTime>
#include <QApplication>
#include <QHeaderView>
#include <QKeyEvent>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QFileDialog>

#include "Vhrmcpu.h"
#include "verilated_save.h"
#include "verilated_vcd_c.h"

//#include "Vhrmcpu_hrmcpu.h"
//#include "Vhrmcpu_PROG.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Clock Initialization
    clk = true;

    bgColor = QString("background-color: rgb(255, 205, 205);");

    // Create our design model with Verilator
    top = new Vhrmcpu;
    top->clk = clk;
    top->eval(); // initialize (so PROG gets loaded)

    // Verilated::internalsDump();  // See scopes to help debug

    // init trace dump
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    //tfp->spTrace()->set_time_resolution ("1 ps");
    tfp->open ("hrmcpu.vcd");
    tfp->dump(main_time);
    tfp->flush(); // any impact on perf? not relevant here

    m_timer = new QTimer(this);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(clkTick()));
    // m_timer->start( ui->clkPeriod->value() );

    // PROG table, set headers
    QStringList LIST;
    for(int i=0; i<256; i++){ LIST.append(formatData(i)); }
    ui->tblPROG->setVerticalHeaderLabels(LIST);
    ui->tblPROG->setHorizontalHeaderLabels(QStringList("Data"));


    // PROG table, fill with current program
    for(int i=0; i<256; i++){
        ui->tblPROG->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__program0__DOT__rom[i] ) ));
    }

    // INBOX table
    for(int i=0; i<32; i++){
        ui->tblINBOX->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__INBOX__DOT__fifo[i] ) ));
    }
    ui->tblINBOX->setVerticalHeaderLabels(LIST.mid(0,16));

    // OUTBOX table
    for(int i=0; i<32; i++){
        ui->tblOUTBOX->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__OUTB__DOT__fifo[i] ) ));
    }
    ui->tblOUTBOX->setVerticalHeaderLabels(LIST.mid(0,16));

    // RAM table, set headers
    LIST.clear();
    for(int i=0; i<16; i++){ LIST.append(QString("%1").arg( i,1,16,QChar('0'))); }
    ui->tblRAM->setVerticalHeaderLabels(LIST);
    LIST.clear();
    for(int i=0; i<16; i++){ LIST.append(QString("_%1").arg(i,1,16,QChar('0'))); }
    ui->tblRAM->setHorizontalHeaderLabels(LIST);

    // Initialize RAM table
    for(int i=0; i<16; i++){
        for(int j=0; j<16; j++){
            ui->tblRAM->setItem(j,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__MEMORY0__DOT__ram0__DOT__mem[16*j+i] ) ));
        }
    }

    ttr_pbPUSH = 0;

    // we force a clock cycle before we give control to the user
//    top->i_rst = true;
//    clkTick();
//    clkTick();
    top->i_rst = false;
    updateUI();
}

MainWindow::~MainWindow()
{
    // we close vcd:
    tfp->flush(); // any impact on perf? not relevant here
    tfp->close();

    delete ui;
}

void MainWindow::clkTick()
{
    clk = ! clk;
    main_time++;

    top->clk = clk;

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

    top->cpu_in_data = ui->editINdata->text().toUInt(&toUintSuccess,16); //ui->editINdata->text().toInt();

    top->eval();
    tfp->dump(main_time);
    tfp->flush(); // any impact on perf? not relevant here

    // Control Block
    ui->clk->setState( clk );
    ui->led_i_rst->setState(top->i_rst);
    ui->main_time->setText( QString("%1").arg( main_time ) );
    ui->led_halt->setState(top->hrmcpu__DOT__cu_halt);

    // PC
    ui->PC_PC->setText(formatData( top->hrmcpu__DOT__PC0_PC ));
    ui->led_PC_branch->setState( top->hrmcpu__DOT__PC0_branch );
    ui->led_PC_ijump->setState( top->hrmcpu__DOT__PC0_ijump );
    ui->led_PC_wPC->setState( top->hrmcpu__DOT__PC0_wPC );
    ui->tblPROG->setCurrentCell(top->hrmcpu__DOT__PC0_PC, 0);
    highlightLabel(ui->PC_PC, top->hrmcpu__DOT__PC0_wPC);

    // PROG
    ui->PROG_ADDR->setText(formatData( top->hrmcpu__DOT__PC0_PC ));
    ui->PROG_DATA->setText(formatData( top->hrmcpu__DOT__program0__DOT__r_data ));
    // PROG table
    for(int i=0; i<256; i++){
        ui->tblPROG->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__program0__DOT__rom[i] ) ));
    }

    // IR Instruction Register
    ui->IR_INSTR->setText(formatData( top->hrmcpu__DOT__IR0_rIR ));
    ui->led_IR_wIR->setState( top->hrmcpu__DOT__cu_wIR );
    ui->IR_INSTR_name->setText( verilatorString( top->hrmcpu__DOT__ControlUnit0__DOT__instrname ) );
    highlightLabel(ui->IR_INSTR, top->hrmcpu__DOT__cu_wIR);

    // Register R
    ui->R_R->setText(formatData( top->hrmcpu__DOT__R_value ));
    ui->led_R_wR->setState( top->hrmcpu__DOT__register0__DOT__wR );
    highlightLabel(ui->R_R, top->hrmcpu__DOT__register0__DOT__wR);

    // RAM
    ui->MEM_AR->setText( formatData( top->hrmcpu__DOT__MEMORY0__DOT__AR_q ) );
    ui->MEM_ADDR->setText( formatData( top->hrmcpu__DOT__MEMORY0__DOT__ADDR ) );
    ui->MEM_DATA->setText( formatData( top->hrmcpu__DOT__MEMORY0__DOT__M ) );
    ui->led_MEM_srcA->setState( top->hrmcpu__DOT__MEMORY0__DOT__srcA );
    ui->led_MEM_wAR->setState( top->hrmcpu__DOT__MEMORY0__DOT__wAR );
    ui->led_MEM_wM->setState( top->hrmcpu__DOT__MEMORY0__DOT__wM );

    // fill RAM table with current values
    for(int i=0; i<16; i++){
        for(int j=0; j<16; j++){
            ui->tblRAM->item(j,i)->setText(formatData( top->hrmcpu__DOT__MEMORY0__DOT__ram0__DOT__mem[16*j+i] ));
        }
    }
    ui->tblRAM->setCurrentCell( (int)( top->hrmcpu__DOT__MEMORY0__DOT__AR_q / 16 ), top->hrmcpu__DOT__MEMORY0__DOT__AR_q % 16 );

    // udpate INBOX leds and Labels
    ui->led_INBOX_empty->setState( ! top->hrmcpu__DOT__INBOX_empty_n );
    ui->led_INBOX_full->setState( top->hrmcpu__DOT__INBOX_full );
    ui->led_INBOX_rd->setState( top->hrmcpu__DOT__INBOX_i_rd );
    ui->INBOX_data->setText( formatData( top->hrmcpu__DOT__INBOX_o_data ) );

    // udpate INBOX table
    for(int i=0; i<32; i++){
        ui->tblINBOX->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__INBOX__DOT__fifo[i] ) ));
    }

    // udpate OUTBOX leds and Labels
    ui->led_OUTBOX_empty->setState( ! top->hrmcpu__DOT__OUTB_empty_n );
    ui->led_OUTBOX_full->setState( top->hrmcpu__DOT__OUTB_full);
//    ui->led_INBOX_rd->setState( top->hrmcpu__DOT__INBOX_i_rd );
//    ui->INBOX_data->setText( formatData( top->hrmcpu__DOT__INBOX_o_data ) );

    // OUTBOX table
    for(int i=0; i<32; i++){
        ui->tblOUTBOX->setItem(0,i,new QTableWidgetItem( formatData( top->hrmcpu__DOT__OUTB__DOT__fifo[i] )));
    }

    if( main_time==ttr_pbPUSH && ui->pbPUSH->isChecked() ) {
        ui->pbPUSH->setChecked(false); // release
        // increment value after each PUSH to Inbox
        // ui->editINdata->setText( QString("%1").arg(ui->editINdata->text().toUInt(&toUintSuccess,16)+1 ,2,16,QChar('0')));
    }
    if( main_time==ttr_pbPOP && ui->pbPOP->isChecked() ) {
        ui->pbPOP->setChecked(false); // release
    }

    ui->cu_statename->setText( verilatorString( top->hrmcpu__DOT__ControlUnit0__DOT__statename ) );

}

void MainWindow::highlightLabel(QWidget *qw, bool signal) {
    if( clk==0 && signal ) {
        qw->setStyleSheet(bgColor);
    } else if (clk==0 && signal == 0) {
        qw->setStyleSheet("");
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

void MainWindow::LoadProgramFromFile(QString fileName)
{
    if (fileName.isEmpty()) {
         qDebug() << "filename is empty, not loading";
        return;
    }

    QFile file(fileName);

    if(!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "error opening file: " << file.error();
        return;
    }

    QTextStream instream(&file);

    QString line = instream.readLine();

//    qDebug() << "first line: " << line;

    QStringList list = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);

//    qDebug() << list;

    bool success;

    for (int i = 0; i < list.size(); ++i)
    {
        top->hrmcpu__DOT__program0__DOT__rom[i] = list.at(i).toUInt(&success,16);
    }
    file.close();

    updateUI();
}

void MainWindow::on_pbLoad_pressed()
{

}

QString MainWindow::verilatorString( WData data[] )
{
    QString s;

    char* p;
    p=(char*)data;

    for(int i=12; i>0; i--) {
        if( p[i-1]>0 ) s.append( p[i-1] );
    }

    return s;
}

void MainWindow::on_pbLoadPROG_pressed()
{
    QString fileName = QFileDialog::getOpenFileName(this,
        tr("Select Program to load"), "",
        tr("Program files (program);;Hex files (*.hex);;All Files (*)"));

    LoadProgramFromFile(fileName);
}

QString MainWindow::formatData(CData data) {
    // for now we don't use mode
    return QString("%1").arg( data ,2,16,QChar('0'));
    // ASCII mode --> return QString("%1").arg( QChar(data) );
}

void MainWindow::on_actionLoad_Program_triggered()
{
    on_pbLoadPROG_pressed();
}

void MainWindow::on_actionExit_triggered()
{
    QApplication::quit();
}
