#
# README file for the CustomCSS Plugin for Movable Type
#

# Overview

This plugin was born out of the need and desire to:

* Provide users with the ability to customize the CSS of a blog, 
  without requiring to give them complete access to edit all the 
  templates of a blog.

* Provide a better interface for editing CSS by devoting a larger
  portion of the screen's real estate to the editor window, unlike
  what is found on Movable Type's default "Edit Template" screen.

* Insulate a theme from a user inadvertantly disrupting a site's
  design by permanently editing or modifying the theme's core CSS
  definition.

The plugin therefore adds a menu item called "Customize Stylesheet"
to the Design menu of Movable Type for those blogs which have 
opted to utilize the Custom CSS feature provided by this plugin.
Clicking that menu item will take users to a screen devoted to
editing a site's stylesheet.

# Prerequisites

Prior to installation, the following requirements must be satisfied:

  * User has MovableType 4.2 or later installed
    - it could work on 4.0, but it has not been tested, nor is it 
      supported.

# Installation

To install this plugin follow the instructions found here:

    http://tinyurl.com/easy-plugin-install

# Usage

By default the "Customize Stylesheet" menu option is not visible
unless one of the two conditions have been met:

* You have enabled "Custom CSS" in your Custom CSS plugin settings
  for the current blog.
* The current blog utilizes a template set for which custom css
  has been enabled.

## Enabling the Custom CSS Menu Item

If you are using a theme that does not explicitly support this plugin, 
but would still like to utilize its functionality, follow these steps:

1. From your blog's dashboard, click "Plugins" from the "Tools" menu.
2. Find "Custom CSS" in the list of plugins and click its name.
3. Click "Settings."
4. Click the check box labeled, "Enable Custom CSS" and hit Save. 

Once the page has reloaded you will see the "Customize Stylesheet" 
option in the Design menu for that blog.

## Embedding Custom CSS into your Stylesheet

This plugin makes available a single template tag: 

    <$mt:CustomCSS$>

This tag will return whatever raw text has been entered into the 
large "Edit Custom CSS" text area. It does *not* process template
tags.

### Example

In an index template in the `<head>` element:

    <style type="text/css">
      <$mt:CustomCSS$>
    </style>

# DESIGNER GUIDE

This plugin allows designers to designate templates within their
template sets which utilize or depend upon user-provided CSS. 
Templates flagged with the 'custom_css' option will be republished
automatically whenever a user makes changes to their custom css.

To flag an index template as one that depends upon custom css, 
consult the example below:

    template_sets:
      mytheme:
        label: 'My Template Set'
        templates:
          index:
            main_index:
              label: 'Main Index'
              outfile: index.html
              rebuild_me: 1
            styles:
              label: Stylesheet
              outfile: styles.css
              rebuild_me: 1
              custom_css: 1

The operative element being the last line above: 

    custom_css: 1

The assumption of course being that the template identified by this
flag contains the `<$mt:CustomCSS$>` tag.

# LICENSE

This plugin is licensed under the GPLv3.
