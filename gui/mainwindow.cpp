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

    m_timer = new QTimer(this);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(clkTick()));
    m_timer->start(500);

    led_on = QPixmap(":/assets/leds/assets/leds/red.svg");
    led_off = QPixmap(":/assets/leds/assets/leds/red_off.svg");


//    m_pTableWidget = new QTableWidget(this);
//    m_pTableWidget->setRowCount(10);
//    m_pTableWidget->setColumnCount(3);
//    m_TableHeader<<"#"<<"Name"<<"Text";
//    m_pTableWidget->setHorizontalHeaderLabels(m_TableHeader);
//    m_pTableWidget->verticalHeader()->setVisible(false);
//    m_pTableWidget->setEditTriggers(QAbstractItemView::NoEditTriggers);
//    m_pTableWidget->setSelectionBehavior(QAbstractItemView::SelectRows);
//    m_pTableWidget->setSelectionMode(QAbstractItemView::SingleSelection);
//    m_pTableWidget->setShowGrid(false);
//    m_pTableWidget->setStyleSheet("QTableView {selection-background-color: red;}");
//    m_pTableWidget->setGeometry(QApplication::desktop()->screenGeometry());

//    //insert data
//    m_pTableWidget->setItem(0, 1, new QTableWidgetItem("Hello"));
//    m_pTableWidget->setItem(0, 1, new QTableWidgetItem("Hello"));

//    ui->tableWidget->setItem(0,0,new QTableWidgetItem("Hello"));
//    ui->tableWidget->item(0,0)->setText("Bah");

    QStringList LIST;
    for(int i=0; i<256; i++){ LIST.append(QString("%1").arg(i,2,16,QChar('0'))); }
    ui->tableWidget->setVerticalHeaderLabels(LIST);
    ui->tableWidget->setHorizontalHeaderLabels(QStringList("Data"));

    top = new Vhrmcpu;
    top->eval();
    for(int i=0; i<256; i++){
        // top->hrmcpu__DOT__program0__DOT__rom[i]
        ui->tableWidget->setItem(0,i,new QTableWidgetItem( QString("%1").arg( top->hrmcpu__DOT__program0__DOT__rom[i] ,2,16,QChar('0')) ));
//        ui->tableWidget->setItem(0,i,new QTableWidgetItem( QString("%1").arg( i ,2,16,QChar('0')) ));
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


// Factorizar los on_..._toggled() en 1 solo y usar el ->sender()->getState/getChecked
// o como sea
void MainWindow::on_pbA_toggled(bool checked)
{
    top->cpu_in_wr=checked?1:0;
    updateUI();
}

void MainWindow::on_pbB_toggled(bool checked)
{
    top->cpu_out_rd=checked?1:0;
    updateUI();
}

void MainWindow::updateUI()
{
    top->eval();

    // Clock
    ui->clk->setPixmap( clk ? led_on : led_off );

    // PC
    ui->PC_PC->setText(QString("%1").arg( top->hrmcpu__DOT__PC0_PC ,2,16,QChar('0')));
    ui->led_PC_branch->setState( top->hrmcpu__DOT__cu_branch );
    ui->led_PC_ijump->setState( top->hrmcpu__DOT__cu_ijump );

    // PROG
    ui->PROG_ADDR->setText(QString("%1").arg( top->hrmcpu__DOT__PC0_PC ,2,16,QChar('0')));
    ui->PROG_DATA->setText(QString("%1").arg( top->hrmcpu__DOT__program0__DOT__r_data ,2,16,QChar('0')));

    // Register R
    ui->R_R->setText(QString("%1").arg( top->hrmcpu__DOT__R_value ,2,16,QChar('0')));
    ui->led_R_wR->setState( top->hrmcpu__DOT__cu_wR );

}
