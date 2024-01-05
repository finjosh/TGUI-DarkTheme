#include <iostream>

#include "SFML/Graphics.hpp"

#include "TGUI/TGUI.hpp"
#include "TGUI/Backend/SFML-Graphics.hpp"

#include "include/Utils/Utils.hpp"
#include "include/Networking/SocketUI.hpp"
#include "include/Networking/Client.hpp"
#include "include/Networking/Server.hpp"

using namespace std;
using namespace sf;

int main()
{
    //! If you want Terminating functions to be attached to the CommandHandler you need to call the initializer
    TFunc::initCommands();
    //! --------------------------

    // setup for sfml and tgui
    sf::RenderWindow window(sf::VideoMode::getDesktopMode(), "Networking Library");
    window.setFramerateLimit(144);
    window.setPosition(Vector2i(-8, -8));

    tgui::Gui gui{window};
    gui.setRelativeView({0, 0, 1920/(float)window.getSize().x, 1080/(float)window.getSize().y});
    tgui::Theme::setDefault("themes/CustomBlack.txt");
    // -----------------------

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

    SocketUI sDisplay(50001);
    // sDisplay.init(gui);
    // sDisplay.setSocket(server);
    sDisplay.initConnectionDisplay(gui);
    sDisplay.setInfoVisible();
    sDisplay.initInfoDisplay(gui);
    sDisplay.setConnectionVisible();

    //! Required to initialize VarDisplay and CommandPrompt
    // creates the UI for the VarDisplay
    VarDisplay::init(gui); 
    // creates the UI for the CommandPrompt
    CommandPrompt::init(gui);
    // create the UI for the TFuncDisplay
    TFuncDisplay::init(gui);
    
    TFuncDisplay::setVisible();
    CommandPrompt::setVisible();
    VarDisplay::setVisible();

    //! ---------------------------------------------------
    
    sf::Clock deltaClock;
    while (window.isOpen())
    {
        window.clear();
        // updating the delta time var
        sf::Time deltaTime = deltaClock.restart();
        sf::Event event;
        while (window.pollEvent(event))
        {
            gui.handleEvent(event);

            //! Required for LiveVar and CommandPrompt to work as intended
            LiveVar::UpdateLiveVars(event);
            CommandPrompt::UpdateEvent(event);
            //! ----------------------------------------------------------

            if (event.type == sf::Event::Closed)
                window.close();
        }
        //! Updates all the vars being displayed
        VarDisplay::Update();
        //! ------------------------------=-----
        //! Updates all Terminating Functions
        TerminatingFunction::UpdateFunctions(deltaTime.asSeconds());
        //* Updates for the terminating functions display
        TFuncDisplay::update();
        //! ------------------------------

        auto temp = sf::RectangleShape({10000,10000});
        temp.setFillColor(sf::Color(50,0,50));
        window.draw(temp);

        sDisplay.update();

        // draw for tgui
        gui.draw();
        // display for sfml window
        window.display();
    }

    sDisplay.closeConnectionDisplay();

    //! Required so that VarDisplay and CommandPrompt release all data
    VarDisplay::close();
    CommandPrompt::close();
    TFuncDisplay::close();
    //! --------------------------------------------------------------

    window.close();

    return 0;
}
