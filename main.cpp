#include <iostream>

#include "SFML/Graphics.hpp"

#include "TGUI/TGUI.hpp"
#include "TGUI/Backend/SFML-Graphics.hpp"

using namespace std;
using namespace sf;

void runExample1(tgui::Gui& gui)
{
    try
    {
        tgui::Theme theme{"themes/Dark.txt"};

        auto tabs = tgui::Tabs::create();
        tabs->setRenderer(theme.getRenderer("Tabs"));
        tabs->setTabHeight(30);
        tabs->setPosition(70, 40);
        tabs->add("Tab - 1");
        tabs->add("Tab - 2");
        tabs->add("Tab - 3");
        gui.add(tabs);

        auto menu = tgui::MenuBar::create();
        menu->setRenderer(theme.getRenderer("MenuBar"));
        menu->addMenu("File");
        menu->addMenuItem("Load");
        menu->addMenuItem("Save");
        menu->addMenuItem("Exit");
        menu->addMenu("Edit");
        menu->addMenuItem("Copy");
        menu->addMenuItem("Paste");
        menu->addMenu("Help");
        menu->addMenuItem("About");
        gui.add(menu);

        auto label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("This is a label.\nAnd these are radio buttons:");
        label->setPosition(10, 90);
        label->setTextSize(18);
        gui.add(label);

        auto radioButton = tgui::RadioButton::create();
        radioButton->setRenderer(theme.getRenderer("RadioButton"));
        radioButton->setPosition(20, 140);
        radioButton->setText("Yep!");
        radioButton->setSize(25, 25);
        gui.add(radioButton);

        radioButton = tgui::RadioButton::create();
        radioButton->setRenderer(theme.getRenderer("RadioButton"));
        radioButton->setPosition(20, 170);
        radioButton->setText("Nope!");
        radioButton->setSize(25, 25);
        gui.add(radioButton);

        radioButton = tgui::RadioButton::create();
        radioButton->setRenderer(theme.getRenderer("RadioButton"));
        radioButton->setPosition(20, 200);
        radioButton->setText("Don't know!");
        radioButton->setSize(25, 25);
        gui.add(radioButton);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("We've got some edit boxes:");
        label->setPosition(10, 240);
        label->setTextSize(18);
        gui.add(label);

        auto editBox = tgui::EditBox::create();
        editBox->setRenderer(theme.getRenderer("EditBox"));
        editBox->setSize(200, 25);
        editBox->setTextSize(18);
        editBox->setPosition(10, 270);
        editBox->setDefaultText("Click to edit text...");
        gui.add(editBox);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("And some list boxes too...");
        label->setPosition(10, 310);
        label->setTextSize(18);
        gui.add(label);

        auto listBox = tgui::ListBox::create();
        listBox->setRenderer(theme.getRenderer("ListBox"));
        listBox->setSize(250, 120);
        listBox->setItemHeight(24);
        listBox->setPosition(10, 340);
        listBox->addItem("Item 1");
        listBox->addItem("Item 2");
        listBox->addItem("Item 3");
        gui.add(listBox);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("It's the progress bar below");
        label->setPosition(10, 470);
        label->setTextSize(18);
        gui.add(label);

        auto progressBar = tgui::ProgressBar::create();
        progressBar->setRenderer(theme.getRenderer("ProgressBar"));
        progressBar->setPosition(10, 500);
        progressBar->setSize(200, 20);
        progressBar->setValue(50);
        gui.add(progressBar);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText(std::to_string(progressBar->getValue()) + "%");
        label->setPosition(220, 500);
        label->setTextSize(18);
        gui.add(label);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("That's the slider");
        label->setPosition(10, 530);
        label->setTextSize(18);
        gui.add(label);

        auto slider = tgui::Slider::create();
        slider->setRenderer(theme.getRenderer("Slider"));
        slider->setPosition(10, 560);
        slider->setSize(200, 18);
        slider->setValue(4);
        gui.add(slider);

        auto scrollbar = tgui::Scrollbar::create();
        scrollbar->setRenderer(theme.getRenderer("Scrollbar"));
        scrollbar->setPosition(380, 40);
        scrollbar->setSize(18, 540);
        scrollbar->setMaximum(100);
        scrollbar->setViewportSize(70);
        gui.add(scrollbar);

        auto comboBox = tgui::ComboBox::create();
        comboBox->setRenderer(theme.getRenderer("ComboBox"));
        comboBox->setSize(120, 21);
        comboBox->setPosition(420, 40);
        comboBox->addItem("Item 1");
        comboBox->addItem("Item 2");
        comboBox->addItem("Item 3");
        comboBox->setSelectedItem("Item 2");
        gui.add(comboBox);

        auto child = tgui::ChildWindow::create();
        child->setRenderer(theme.getRenderer("ChildWindow"));
        child->setSize(250, 120);
        child->setPosition(420, 80);
        child->setTitle("Child window");
        gui.add(child);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("Hi! I'm a child window.");
        label->setPosition(30, 30);
        label->setTextSize(15);
        child->add(label);

        auto button = tgui::Button::create();
        button->setRenderer(theme.getRenderer("Button"));
        button->setPosition(75, 70);
        button->setText("OK");
        button->setSize(100, 30);
        button->onClick([=](){ child->setVisible(false); });
        child->add(button);

        auto checkbox = tgui::CheckBox::create();
        checkbox->setRenderer(theme.getRenderer("CheckBox"));
        checkbox->setPosition(420, 240);
        checkbox->setText("Ok, I got it");
        checkbox->setSize(25, 25);
        gui.add(checkbox);

        checkbox = tgui::CheckBox::create();
        checkbox->setRenderer(theme.getRenderer("CheckBox"));
        checkbox->setPosition(570, 240);
        checkbox->setText("No, I didn't");
        checkbox->setSize(25, 25);
        gui.add(checkbox);

        label = tgui::Label::create();
        label->setRenderer(theme.getRenderer("Label"));
        label->setText("Chatbox");
        label->setPosition(420, 280);
        label->setTextSize(18);
        gui.add(label);

        auto chatbox = tgui::ChatBox::create();
        chatbox->setRenderer(theme.getRenderer("ChatBox"));
        chatbox->setSize(300, 100);
        chatbox->setTextSize(18);
        chatbox->setPosition(420, 310);
        chatbox->setLinesStartFromTop();
        chatbox->addLine("texus: Hey, this is TGUI!", sf::Color::Green);
        chatbox->addLine("Me: Looks awesome! ;)", sf::Color::Yellow);
        chatbox->addLine("texus: Thanks! :)", sf::Color::Green);
        chatbox->addLine("Me: The widgets rock ^^", sf::Color::Yellow);
        gui.add(chatbox);

        button = tgui::Button::create();
        button->setRenderer(theme.getRenderer("Button"));
        button->setPosition(gui.getWindow()->getSize().x - 115.f, gui.getWindow()->getSize().y - 50.f);
        button->setText("Exit");
        button->setSize(100, 40);
        button->onClick([&](){ gui.getWindow()->close(); } );        
        gui.add(button);
    }
    catch (const tgui::Exception& e)
    {
        std::cerr << "TGUI Exception: " << e.what() << std::endl;
    }
}

void runExample2(tgui::Gui& gui)
{
    gui.add(tgui::BitmapButton::create("BitBtn"));
    gui.getWidgets().back()->setPosition(10,10);
    gui.add(tgui::Button::create("Button"));
    gui.getWidgets().back()->setPosition(90,10);
    gui.add(tgui::CheckBox::create("Check Box"));
    gui.getWidgets().back()->setPosition(180,10);
    gui.add(tgui::ChildWindow::create("Child Window"));
    gui.getWidgets().back()->setPosition(10,210);
    gui.getWidgets().back()->cast<tgui::ChildWindow>()->add(tgui::ListBox::create());
    gui.add(tgui::ComboBox::create());
    gui.getWidgets().back()->setPosition(310,10);
    gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box");
    gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box1");
    gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box2");
    gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box3");
    gui.add(tgui::EditBox::create());
    gui.getWidgets().back()->setPosition(10,600);
    gui.getWidgets().back()->cast<tgui::EditBox>()->setDefaultText("Edit Box");
    gui.add(tgui::FileDialog::create("File Dialog"));
    gui.getWidgets().back()->setPosition(900,200);
    gui.add(tgui::Knob::create());
    gui.getWidgets().back()->setPosition(300,50);
    gui.add(tgui::Label::create("Label"));
    gui.getWidgets().back()->setPosition(510,10);
    gui.add(tgui::ListBox::create());
    gui.getWidgets().back()->setPosition(470,50);
    auto l = gui.getWidgets().back()->cast<tgui::ListBox>();
    l->addItem("A Item");
    l->addItem("A");
    l->addItem("Item");
    l->addItem("Another Item");
    l->addItem("Some Item");
    l->addItem("A Item");
    l->addItem("A");
    l->addItem("Item");
    l->addItem("Another Item");
    l->addItem("Some Item");
    gui.add(tgui::ListView::create());
    gui.getWidgets().back()->setPosition(470,210);
    auto t = gui.getWidgets().back()->cast<tgui::ListView>();
    t->addColumn("A Column");
    t->addColumn("Another Column");
    t->addColumn("Some Other Column");
    t->addItem({"Some Random Item", "More than one column", "A Third"});
    t->addItem({"Some Random Item2", "More than one column2", "A Third2"});
    t->addItem({"Some Random Item3", "More than one column3", "A Third3"});
    t->addItem({"Some Random Item4", "More than one column4", "A Third4"});
    t->addItem({"Some Random Item5", "More than one column5", "A Third5"});
    gui.add(tgui::ProgressBar::create());
    gui.getWidgets().back()->setPosition(130,530);
    gui.getWidgets().back()->cast<tgui::ProgressBar>()->setValue(30);
    gui.add(tgui::RangeSlider::create());
    gui.getWidgets().back()->setPosition(130,650);
    gui.add(tgui::SeparatorLine::create());
    gui.getWidgets().back()->setPosition(900,0);
    gui.add(tgui::Slider::create());
    gui.getWidgets().back()->setPosition(130,700);
    gui.add(tgui::SpinControl::create());
    gui.getWidgets().back()->setPosition(150,42);
    gui.add(tgui::Tabs::create());
    gui.getWidgets().back()->setPosition(680,120);
    gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab");
    gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab2");
    gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab3");
    gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab4");
    gui.add(tgui::TextArea::create());
    gui.getWidgets().back()->setPosition(470,600);
    gui.getWidgets().back()->cast<tgui::TextArea>()->setDefaultText("Text Area");
    gui.add(tgui::ToggleButton::create("Toggle Button"));
    gui.getWidgets().back()->setPosition(130,790);
    gui.add(tgui::TreeView::create());
    gui.getWidgets().back()->setPosition(470,800);
    auto temp = gui.getWidgets().back()->cast<tgui::TreeView>();
    temp->addItem({"Tree", "Item", "Another Item"});
    temp->addItem({"Tree", "Item2", "Another Item"});
    temp->addItem({"Tree", "Something Else", "Another Item"});
    temp->addItem({"Tree2", "Item1", "Another Item"});
    temp->addItem({"Tree2", "Item4", "Another Item"});
    temp->addItem({"Tree2", "Item6", "Why"});
}

int main()
{
    // setup for sfml and tgui
    sf::RenderWindow window(sf::VideoMode::getDesktopMode(), "Networking Library");
    window.setFramerateLimit(144);
    window.setPosition(Vector2i(-8, -8));

    tgui::Gui gui{window};
    gui.setRelativeView({0, 0, 1920/(float)window.getSize().x, 1080/(float)window.getSize().y});
    tgui::Theme::setDefault("themes/Dark.txt");
    // -----------------------

    // runExample1(gui);
    runExample2(gui);

    while (window.isOpen())
    {
        window.clear();
        sf::Event event;
        while (window.pollEvent(event))
        {
            gui.handleEvent(event);

            if (event.type == sf::Event::Closed)
                window.close();
        }
        
        auto temp = sf::RectangleShape({10000,10000});
        temp.setFillColor(sf::Color(100,100,100));
        window.draw(temp);

        // draw for tgui
        gui.draw();
        // display for sfml window
        window.display();
    }

    window.close();

    return 0;
}
