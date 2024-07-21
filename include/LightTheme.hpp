#ifndef LIGHT_THEME_HPP
#define LIGHT_THEME_HPP
#pragma once
#include "TGUI/Loading/Theme.hpp"
/// @brief this is the same theme that is stored in the txt file
/// @note this is so that your program does not require any extra external dependencies like txt files
struct LightTheme : tgui::Theme{LightTheme();};
#endif