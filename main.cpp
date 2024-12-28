#include <iostream>
#include <filesystem>
#include <fstream>

#include "SFML/Graphics.hpp"

#include "TGUI/TGUI.hpp"
#include "TGUI/Backend/SFML-Graphics.hpp"
#include "TGUI/AllWidgets.hpp"

using namespace std;

// void runExample(tgui::Gui& gui)
// {
//     gui.add(tgui::BitmapButton::create("BitBtn"));
//     gui.getWidgets().back()->setPosition(10,10);
//     gui.add(tgui::Button::create("Button"));
//     gui.getWidgets().back()->setPosition(90,10);
//     gui.add(tgui::CheckBox::create("Check Box"));
//     gui.getWidgets().back()->setPosition(180,10);
//     gui.add(tgui::ChildWindow::create("Child Window"));
//     gui.getWidgets().back()->setPosition(10,210);
//     gui.getWidgets().back()->cast<tgui::ChildWindow>()->add(tgui::ListBox::create());
//     gui.add(tgui::ComboBox::create());
//     gui.getWidgets().back()->setPosition(310,10);
//     gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box");
//     gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box1");
//     gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box2");
//     gui.getWidgets().back()->cast<tgui::ComboBox>()->addItem("Combo Box3");
//     gui.add(tgui::EditBox::create());
//     gui.getWidgets().back()->setPosition(10,600);
//     gui.getWidgets().back()->cast<tgui::EditBox>()->setDefaultText("Edit Box");
//     gui.add(tgui::FileDialog::create("File Dialog"));
//     gui.getWidgets().back()->setPosition(1100,200);
//     gui.add(tgui::Knob::create());
//     gui.getWidgets().back()->setPosition(300,50);
//     gui.add(tgui::Label::create("Label"));
//     gui.getWidgets().back()->setPosition(510,10);
//     gui.add(tgui::ListBox::create());
//     gui.getWidgets().back()->setPosition(470,50);
//     auto l = gui.getWidgets().back()->cast<tgui::ListBox>();
//     l->addItem("A Item");
//     l->addItem("A");
//     l->addItem("Item");
//     l->addItem("Another Item");
//     l->addItem("Some Item");
//     l->addItem("A Item");
//     l->addItem("A");
//     l->addItem("Item");
//     l->addItem("Another Item");
//     l->addItem("Some Item");
//     gui.add(tgui::ListView::create());
//     gui.getWidgets().back()->setPosition(470,210);
//     auto t = gui.getWidgets().back()->cast<tgui::ListView>();
//     t->addColumn("A Column");
//     t->addColumn("Another Column");
//     t->addColumn("Some Other Column");
//     t->addItem({"Some Random Item", "More than one column", "A Third"});
//     t->addItem({"Some Random Item2", "More than one column2", "A Third2"});
//     t->addItem({"Some Random Item3", "More than one column3", "A Third3"});
//     t->addItem({"Some Random Item4", "More than one column4", "A Third4"});
//     t->addItem({"Some Random Item5", "More than one column5", "A Third5"});
//     gui.add(tgui::ProgressBar::create());
//     gui.getWidgets().back()->setPosition(130,530);
//     gui.getWidgets().back()->cast<tgui::ProgressBar>()->setValue(30);
//     gui.add(tgui::RangeSlider::create());
//     gui.getWidgets().back()->setPosition(130,650);
//     gui.add(tgui::SeparatorLine::create());
//     gui.getWidgets().back()->setPosition(900,0);
//     gui.add(tgui::Slider::create());
//     gui.getWidgets().back()->setPosition(130,700);
//     gui.add(tgui::SpinControl::create());
//     gui.getWidgets().back()->setPosition(150,42);
//     gui.add(tgui::Tabs::create());
//     gui.getWidgets().back()->setPosition(680,120);
//     gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab");
//     gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab2");
//     gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab3");
//     gui.getWidgets().back()->cast<tgui::Tabs>()->add("Tab4");
//     gui.add(tgui::TextArea::create());
//     gui.getWidgets().back()->setPosition(470,600);
//     gui.getWidgets().back()->cast<tgui::TextArea>()->setDefaultText("Text Area");
//     gui.add(tgui::ToggleButton::create("Toggle Button"));
//     gui.getWidgets().back()->setPosition(130,790);
//     gui.add(tgui::TreeView::create());
//     gui.getWidgets().back()->setPosition(470,800);
//     auto temp = gui.getWidgets().back()->cast<tgui::TreeView>();
//     temp->addItem({"Tree", "Item", "Another Item"});
//     temp->addItem({"Tree", "Item2", "Another Item"});
//     temp->addItem({"Tree", "Something Else", "Another Item"});
//     temp->addItem({"Tree2", "Item1", "Another Item"});
//     temp->addItem({"Tree2", "Item4", "Another Item"});
//     temp->addItem({"Tree2", "Item6", "Why"});
//     gui.add(tgui::ScrollablePanel::create({"15%","15%"}));
//     gui.getWidgets().back()->setPosition(700,200);
//     gui.getWidgets().back()->cast<tgui::ScrollablePanel>()->add(tgui::FileDialog::create()); // Adding a bigger widget so the scroll bars show
//     gui.add(tgui::Panel::create({200,200}));
//     gui.getWidgets().back()->setPosition(500,375);
// }

void makeAllWidgets(tgui::Gui& gui, const std::string& defaultTheme)
{
    auto widgetHolder = tgui::HorizontalWrap::create();
    auto themeSelector = tgui::ComboBox::create();
    for (auto dir: std::filesystem::directory_iterator("themes"))
    {
        themeSelector->addItem(dir.path().generic_string());
    }
    themeSelector->onItemSelect([](tgui::String selected){
        tgui::Theme::getDefault()->replace(selected);
    });
    themeSelector->setSelectedItem(defaultTheme);
    widgetHolder->add(themeSelector);
    auto scroll = tgui::ScrollablePanel::create();
    scroll->add(widgetHolder);
    widgetHolder->getRenderer()->setSpaceBetweenWidgets(10);

    for (auto widgetName: tgui::WidgetFactory::getWidgetTypes())
    {
        if (widgetName == "RadioButtonGroup") // just look at the radio button
            continue;

        auto panel = tgui::Panel::create();
        auto label = tgui::Label::create(widgetName);
        label->setHorizontalAlignment(tgui::HorizontalAlignment::Center);
        label->setVerticalAlignment(tgui::VerticalAlignment::Center);
        panel->add(label);
        float temp = panel->getWidgets().back()->getSize().y;
        panel->add(tgui::WidgetFactory::getConstructFunction(widgetName)());
        auto lastWidget = panel->getWidgets().back();
        lastWidget->setPosition(0, temp);
        temp += lastWidget->getFullSize().y;
        
        if (widgetName == "ChatBox")
        {
            auto chat = lastWidget->cast<tgui::ChatBox>();
            chat->addLine("Adding 500 random lines");
            chat->setLineLimit(1000);
            for (int i = 0; i < 500; i++)
            {
                tgui::String temp;
                for (int i = 0; i < 10; i++)
                {
                    temp += char(rand()%25+65);
                }
                chat->addLine(temp);
            }
        }
        else if (widgetName == "MessageBox")
        {
            auto msg = lastWidget->cast<tgui::MessageBox>();
            msg->setText("Some random message for the message box");
        }
        else if (auto container = lastWidget->cast<tgui::Container>())
        {
            int maxImages = INT_MAX;
            if (widgetName == "SplitContainer")
            {
                maxImages = 2;
            }
            if (widgetName == "ChildWindow")
                container->cast<tgui::ChildWindow>()->setTitleButtons(tgui::ChildWindow::TitleButton::Close | tgui::ChildWindow::TitleButton::Maximize | tgui::ChildWindow::TitleButton::Minimize);
            if (widgetName != "ColorPicker" && widgetName != "FileDialog")
            for (auto file: std::filesystem::directory_iterator{"TestPhotos"})
            {
                if (maxImages <= 0)
                    break;
                auto picture = tgui::Picture::create(tgui::Texture{file.path().generic_string()});
                picture->setSize({100, 100*(picture->getSize().y/picture->getSize().x)});
                container->add(picture); // can have many overlapping photos but we also want to show if the container sorts the widgets
                
                if (widgetName != "SplitContainer")
                {
                    container->updateChildrenWithAutoLayout();
                    float width = 0;
                    float height = 0;
                    for (auto widget: container->getWidgets())
                    {
                        if (widget->getFullSize().x > width)
                            width = widget->getFullSize().x;
                        float temp = widget->getPosition().y + widget->getFullSize().y;
                        if (temp > height)
                            height = temp;
                    }
                    container->setSize({width, height});
                }
                else
                {
                    container->setSize("100%", container->getSize().y < picture->getSize().y ? picture->getSize().y : container->getSize().y);
                }

                maxImages--;
            }
        }
        else if (auto button = lastWidget->cast<tgui::Button>())
        {
            button->setText(widgetName + " Text");
            auto disabled = lastWidget->clone()->cast<tgui::Button>();
            disabled->setPosition({0, temp});
            disabled->setEnabled(false);
            disabled->setText(widgetName + " Text (Disabled)");
            panel->add(disabled);
        }
        else if (widgetName == "ProgressBar")
        {
            auto progress = lastWidget->cast<tgui::ProgressBar>();
            progress->setMaximum(999);
            progress->setValue(rand()%1000);
        }
        else if (widgetName == "ComboBox")
        {
            auto box = lastWidget->cast<tgui::ComboBox>();
            box->addItem("Combo Box");
            box->addItem("Combo Box1");
            box->addItem("Combo Box2");
            box->addItem("Combo Box3");
            box->setSelectedItemByIndex(0);
        }
        else if (widgetName == "Label")
        {
            lastWidget->cast<tgui::Label>()->setText("Epic label");
        }
        else if (widgetName == "RichTextLabel")
        {
            lastWidget->cast<tgui::RichTextLabel>()->setMaximumTextWidth(200);
            lastWidget->cast<tgui::RichTextLabel>()->setText("The RichTextLabel widget supports formatting text with <b>bold</b>, <i>italics</i>, <u>underlined</u> "
                "and even <s>strikethrough</s>. Each letter can have a separate <size=15>size</size> or <color=blue>color</color>. "
                "This allows for some <b><color=#ff0000>C</color><color=#ffbf00>O</color><color=#80ff00>L</color>"
                "<color=#00ff40>O</color><color=#00ffff>R</color><color=#0040ff>F</color><color=#7f00ff>U</color>"
                "<color=#ff00bf>L</color></b> text. Lines that are too long will wrap around and a vertical scrollbar can be included "
                "when there are too many lines!");
        }
        else if (widgetName == "Picture")
        {
            for (auto file: std::filesystem::directory_iterator{"TestPhotos"})
            {
                lastWidget->cast<tgui::Picture>()->getRenderer()->setTexture({file.path().generic_string()});
                if (rand()%2) // pick random breaking point
                    break;
            }
        }
        else if (widgetName == "SeparatorLine")
        {
            lastWidget->setHeight(25);
            lastWidget->setWidth(5);
            lastWidget->setPosition({"50%", lastWidget->getPosition().y});
        }
        else if (widgetName == "RangeSlider")
        {
            auto slider = lastWidget->cast<tgui::RangeSlider>();
            slider->setMinimum(0);
            slider->setMaximum(999);
            slider->setSelectionStart(rand()%500);
            slider->setSelectionEnd(rand()%500+500);
        }
        else if (widgetName == "ListBox")
        {
            auto list = lastWidget->cast<tgui::ListBox>();
            list->addItem("Some Item");
            list->addItem("Another Item");
            list->addItem("I don't know what else to put");
            list->addItem("Something");
            list->addItem("Cat");
        }
        else if (widgetName == "ListView")
        {
            auto list = lastWidget->cast<tgui::ListView>();
            list->setResizableColumns(true);
            list->addColumn("Name");
            list->addColumn("Value");
            list->addColumn("Something Else");
            list->addItem({"Cat", "100", "..."});
            list->addItem({"a item", "13", "something"});
            list->addItem({"something", "54", "..."});
            list->addItem({"i dont know", "67", "who knows"});
            list->addItem({"anything", "62", "..."});
        }
        else if (widgetName == "MenuBar")
        {
            auto bar = lastWidget->cast<tgui::MenuBar>();
            bar->addMenu("Disabled");
            bar->setMenuEnabled("Disabled", false);
            bar->addMenu("Enabled");
            bar->addMenuItem("Enabled", "Menu Item");
            bar->setSize({200, 50});
        }
        else if (widgetName == "Tabs")
        {
            auto tabs = lastWidget->cast<tgui::Tabs>();
            tabs->add("Some Tab");
            tabs->add("Another Tab");
            tabs->add("Cats!");
            tabs->add("Yet Another Tab");
        }
        else if (widgetName == "TreeView")
        {
            auto tree = lastWidget->cast<tgui::TreeView>();
            tree->addItem({"Root", "Branch", "Branch Branch", "Leaf"});
            tree->addItem({"Cats", "more Cats?", "Even more cats", "so many cats"});
            tree->addItem({"Why Cats?", "Cats are cool"});
        }
        
        widgetHolder->add(panel);

        float width = 0;
        float height = 0;
        for (auto widget: panel->getWidgets())
        {
            if (widget->getFullSize().x > width)
                width = widget->getFullSize().x;
            height += widget->getFullSize().y;
        }
        panel->setSize({width + panel->getSharedRenderer()->getPadding().getLeft() + panel->getSharedRenderer()->getPadding().getRight() + 5, 
                        height + panel->getSharedRenderer()->getPadding().getTop() + panel->getSharedRenderer()->getPadding().getBottom() + 5});
    }

    widgetHolder->updateChildrenWithAutoLayout();
    widgetHolder->setSize({"100%", widgetHolder->getWidgets().back()->getPosition().y + widgetHolder->getWidgets().back()->getFullSize().y + 15}); // have to get last widget because size does not update for some reason
    scroll->setContentSize({scroll->getSize().x, widgetHolder->getFullSize().y}); 
    gui.add(scroll);
}

void createCppTheme(const std::string& themePath)
{
    tgui::Theme theme;
    try
    {
        theme.load(themePath);
    }
    catch(const std::exception& e)
    {
        throw std::runtime_error("Theme path does not store a theme");
    }

    tgui::String name = std::filesystem::path(themePath).filename().replace_extension("").generic_string();
    std::string className = name.toStdString() + "Theme";

    assert((!std::filesystem::exists(className + ".hpp")) && "Class already exists");

    {
    std::ofstream header(className + ".hpp");
    header << "#ifndef " << name.toUpper().toStdString() << "_" << "THEME_HPP" << "\n#define " << name.toUpper() << "_" << "THEME_HPP" << "\n#pragma once"; // adding header define stuff
    header << "/// @brief this is the same theme that is stored in the txt file\n/// @note this is so that your program does not require any extra external dependencies like txt files";
    header << "\n#include \"TGUI/Loading/Theme.hpp\"" << "\nstruct " << className << " : tgui::Theme" << "{" << className << "();" << "};" << "\n"; // defining the class and its constructor
    header << "#endif"; // end of head file
    }

    // making the cpp file
    std::ofstream source(className + ".cpp");
    source << "#include \"" << className << ".hpp" << "\"\n" << className << "::" << className << "()\n{"; // including and starting the constructor

    bool isFirst = true;

    source << "m_renderers = {";
    for (auto widgetName: tgui::WidgetFactory::getWidgetTypes())
    {
        std::map<tgui::String, tgui::ObjectConverter> properties;
        try
        {
            properties = theme.getRenderer(widgetName)->propertyValuePairs;
        }
        catch(const std::exception& e)
        {
            std::cerr << e.what() << '\n';
            source << "})";
        }

        if (!isFirst)
            source << ",";
        else
            isFirst = false;
        source << "{\"" << widgetName.toStdString() << "\", tgui::RendererData::create({";

        bool isFirst2 = true;

        for (auto property: properties)
        {
            if (!isFirst2)
                source << ",";
            else
                isFirst2 = false;

            source << "{\"" << property.first << "\",\"" <<  std::regex_replace(property.second.getString().toStdString(), std::regex("\n"), "\\n") << "\"}";
        }

        source << "})}";
    }
    source << "};";

    isFirst = true;

    source << "m_globalProperties = {";
    for (auto property: tgui::Theme::getThemeLoader()->getGlobalProperties(themePath))
    {
        if (!isFirst)
            source << ",";
        else
            isFirst = false;

        source << "{\"" << property.first.toStdString() << "\",\"" << std::regex_replace(property.second.toStdString(), std::regex("\n"), "\\n") << "\"}";
    }
    source << "};";

    source << "}"; // ending the constructor
}

#include "DarkTheme.hpp"
int main()
{
    // createCppTheme("themes/Light.txt");
    // createCppTheme("themes/Dark.txt");

    // return EXIT_SUCCESS;

    // setup for sfml and tgui
    sf::RenderWindow window(sf::VideoMode::getDesktopMode(), "TGUI-Dark");
    window.setFramerateLimit(144);
    window.setPosition(sf::Vector2i(-8, -8));

    tgui::Gui gui{window};
    gui.setRelativeView({0, 0, 1920/(float)window.getSize().x, 1080/(float)window.getSize().y});
    // -----------------------
    
    // runExample(gui);
    makeAllWidgets(gui, "");
    tgui::Theme::getDefault()->replace(DarkTheme());

    while (window.isOpen())
    {
        window.clear();
        while (const std::optional<sf::Event> event = window.pollEvent())
        {
            gui.handleEvent(event.value());

            if (event->is<sf::Event::Closed>())
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
