# Most useful targets:
#
#   all (default target) --
#     Compile all units
#   any subdirectory name, like base or 3d --
#     Compile all units inside that subdirectory (and all used units
#     in other directories)
#
#   info --
#     Some information about what this Makefile sees, how will it work etc.
#
#   examples --
#     Compile all examples and tools (things inside examples/ and tools/
#     subdirectories). Note that you can also compile each example separately,
#     just run appropriate xxx_compile.sh scripts.
#
#   clean --
#     Delete FPC 1.0.x Windows trash (*.ppw, *.ow), FPC trash, Delphi trash,
#     Lazarus trash (*.compiled),
#     binaries of example programs,
#     also FPC compiled trash in packages/*/lib/,
#     and finally pasdoc generated documentation in doc/pasdoc/
#
# Not-so-commonly-useful targets:
#
#   container_units --
#     Create special container All*Units.pas units in all subdirectories.
#     Note that regenerating these units is not so easy -- you'll
#     need Emacs and my kambi-pascal-functions.el Elisp
#     code to do it (available inside SVN repository,
#     see http://michalis.ii.uni.wroc.pl/).
#
#   cleanmore --
#     Same as clean + delete Emacs backup files (*~) and Delphi backup files
#     (*.~??? (using *.~* would be too unsafe ?))
#
#   clean_container_units --
#     Cleans special units All*Units.pas.
#     This may be uneasy to undo, look at comments at container_units.
#
#   cleanall --
#     Same as cleanmore + clean_container_units.
#     This target should not be called unless you know
#     that you really want to get rid of ALL files that can be automatically
#     regenerated. Note that some of the files deleted by this target may
#     be not easy to regenerate -- see comments at container_units.
#
# Internal notes (not important if you do not want to read/modify
# this Makefile):
#
# Note: In many places in this Makefile I'm writing some special code
# to not descend to 'private' and 'old' subdirectories.
# This is something that is usable only for me (Michalis),
# if you're trying to understand this Makefile you can just ignore
# such things (you may be sure that I will never have here directory
# called 'private' or 'old').
#
# This Makefile must be updated when adding new subdirectory to my units.
# To add new subdirectory foo, add rules
# 1. rule 'foo' to compile everything in foo
# 2. rule to recreate file foo/allkambifoounits.pas
# 3. add to $(ALL_CONTAINER_UNITS) to delete on clean_container_units

# compiling ------------------------------------------------------------

# UNITS_SUBDIRECTORIES used to be generated by such rule:
#
# $(shell \
#   find * -maxdepth 0 -type d \
#     '(' -not -name 'private' ')' '(' -not -name 'old' ')' \
#     '(' -not -name 'packages' ')' '(' -not -name 'doc' ')' \
#     -print)
#
# but I removed it, now units subdirectories are just specified explicitly.
# Reason: 1. $(shell find) requires Unix "find", so it's a problem for Windows users
# (requires Cygwin or MinGW, FPC distribution contains "make" but not "find"),
# 2. Units subdirectories rules (see below) have to be listed explicitly anyway,
# so it's not a big deal to also list them explicitly for UNITS_SUBDIRECTORIES.
#
UNITS_SUBDIRECTORIES := 3d 3d.opengl vrml vrml.opengl audio base \
  fonts images net opengl kambiscript ui ui.opengl glwindow

.PHONY: all
all: $(UNITS_SUBDIRECTORIES)

# compiling rules for each subdirectory

.PHONY: $(UNITS_SUBDIRECTORIES)

COMPILE_ALL_DIR_UNITS=fpc -dRELEASE @kambi.cfg $<

3d: src/3d/allkambi3dunits.pas
	$(COMPILE_ALL_DIR_UNITS)

3d.opengl: src/3d/opengl/allkambi3dglunits.pas
	$(COMPILE_ALL_DIR_UNITS)

vrml.opengl: src/vrml/opengl/allkambivrmlglunits.pas
	$(COMPILE_ALL_DIR_UNITS)

vrml: src/vrml/allkambivrmlunits.pas
	$(COMPILE_ALL_DIR_UNITS)

audio: src/audio/allkambiaudiounits.pas
	$(COMPILE_ALL_DIR_UNITS)

base: src/base/allkambibaseunits.pas
	$(COMPILE_ALL_DIR_UNITS)

fonts: src/fonts/allkambifontsunits.pas
	$(COMPILE_ALL_DIR_UNITS)

images: src/images/allkambiimagesunits.pas
	$(COMPILE_ALL_DIR_UNITS)

opengl: src/opengl/allkambiopenglunits.pas
	$(COMPILE_ALL_DIR_UNITS)

kambiscript: src/kambiscript/allkambiscriptunits.pas
	$(COMPILE_ALL_DIR_UNITS)

ui: src/ui/allkambiuiunits.pas
	$(COMPILE_ALL_DIR_UNITS)

ui.opengl: src/ui/opengl/allkambiuiglunits.pas
	$(COMPILE_ALL_DIR_UNITS)

glwindow: src/glwindow/allkambiglwindowunits.pas
	$(COMPILE_ALL_DIR_UNITS)

# creating All*Units.pas files ----------------------------------------

.PHONY: container_units clean_container_units

EMACS_BATCH := emacs -batch --eval="(require 'kambi-pascal-functions)"

ALL_CONTAINER_UNITS := src/3d/allkambi3dunits.pas \
  src/3d/opengl/allkambi3dglunits.pas \
  src/vrml/opengl/allkambivrmlglunits.pas \
  src/vrml/allkambivrmlunits.pas \
  src/audio/allkambiaudiounits.pas \
  src/base/allkambibaseunits.pas \
  src/fonts/allkambifontsunits.pas \
  src/images/allkambiimagesunits.pas \
  src/opengl/allkambiopenglunits.pas \
  src/kambiscript/allkambiscriptunits.pas \
  src/ui/allkambiuiunits.pas \
  src/ui/opengl/allkambiuiglunits.pas \
  src/glwindow/allkambiglwindowunits.pas

# This is a nice target to call before doing a distribution of my sources,
# because I always want to distribute these All*Units.pas units.
# (so noone except me should ever need to run emacs to generate them)
container_units: $(ALL_CONTAINER_UNITS)

clean_container_units:
	rm -f $(ALL_CONTAINER_UNITS)

src/3d/allkambi3dunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"3d/\" \"AllKambi3dUnits\") \
  (save-buffer))"

src/3d/opengl/allkambi3dglunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"3d/opengl/\" \"AllKambi3dGLUnits\") \
  (save-buffer))"

src/vrml/opengl/allkambivrmlglunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"vrml/opengl/\" \"AllKambiVRMLGLUnits\") \
  (save-buffer))"

src/vrml/allkambivrmlunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"vrml/\" \"AllKambiVRMLUnits\") \
  (save-buffer))"

src/audio/allkambiaudiounits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"audio/\" \"AllKambiAudioUnits\") \
  (save-buffer))"

src/base/allkambibaseunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"base/\" \"AllKambiBaseUnits\") \
  (kam-simple-replace-buffer \"kambixmlread,\" \"{ kambixmlread, --- kambixmlread will be compiled only if required by other units (as it's only for some FPC versions) }\") \
  (save-buffer))"

# FIXME: kam-simple-replace-buffer here is dirty hack to correct problems
# with all-units-in-dir
src/fonts/allkambifontsunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"fonts/\" \"AllKambiFontsUnits\") \
  (kam-simple-replace-buffer \"ttfontstypes,\" \"ttfontstypes {\$$ifdef MSWINDOWS}, {\$$endif}\") \
  (save-buffer))"

src/images/allkambiimagesunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"images/\" \"AllKambiImagesUnits\") \
  (kam-simple-replace-buffer \"imagesfftw,\" \"{ imagesfftw, --- imagesfftw is not compiled here for now, as it requires FPC > 2.2.x, and is not actually used by anything else from the engine }\") \
  (save-buffer))"

src/opengl/allkambiopenglunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"opengl/\" \"AllKambiOpenGLUnits\") \
  (kam-simple-replace-buffer \"shadowvolumes,\" \"shadowvolumes {\$$ifdef MSWINDOWS}, {\$$endif}\") \
  (save-buffer))"

src/kambiscript/allkambiscriptunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"kambiscript/\" \"AllKambiScriptUnits\") \
  (save-buffer))"

src/ui/allkambiuiunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"ui/\" \"AllKambiUIUnits\") \
  (save-buffer))"

src/ui/opengl/allkambiuiglunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"ui/opengl/\" \"AllKambiUIGLUnits\") \
  (save-buffer))"

src/glwindow/allkambiglwindowunits.pas:
	$(EMACS_BATCH) --eval="(progn \
  (write-unit-all-units-in-dir \"glwindow/\" \"AllKambiGLWindowUnits\") \
  (save-buffer))"

# examples and tools -----------------------------------------------------------

# Note that images/examples/fft_tests is not included here,
# and unit images/imagesfftw.pas is not included in allimagesunits.pas
# (and fpmake.pp doesn't include imagesfftw.pas),
# because
# 1. it requires to compile FPC > 2.2.x, which currently means that you
#    have to use FPC from SVN trunk.
# 2. to link the example, you need the fftw library. I don't want
#    to force everyone who wants to execute "make examples" to install
#    fftw library (especially since it's really not needed by my engine,
#    currently my fftw code is just for testing, it's not actually used
#    by VRML engine or any game for anything).

EXAMPLES_BASE_NAMES := \
  examples/audio/algets \
  examples/audio/alplay \
  examples/audio/doppler_demo \
  examples/audio/efx_demo \
  examples/base/demo_parseparameters \
  examples/base/demo_textreader \
  examples/base/test_platform_specific_utils \
  examples/kambiscript/kambi_calc \
  examples/kambiscript/image_make_by_script \
  examples/base/svg_grayscale \
  examples/base/stringoper \
  examples/images/image_convert \
  examples/images/dds_decompose \
  examples/images/image_identify \
  examples/images/image_to_pas \
  examples/images/dds_remove_small_mipmaps \
  examples/glwindow/gl_win_events \
  examples/glwindow/menu_test_alternative \
  examples/glwindow/menu_test \
  examples/glwindow/test_glwindow_gtk_mix \
  examples/glwindow/test_font_break \
  examples/glwindow/multi_glwindow \
  examples/glwindow/multi_texturing_demo \
  examples/glwindow/shading_langs/shading_langs_demo \
  examples/glwindow/demo_camera \
  examples/glwindow/fog_coord \
  examples/glwindow/simple_video_editor \
  examples/glwindow/test_menu_change_from_keyup \
  examples/glwindow/bezier_surfaces/animate_surface \
  examples/glwindow/bezier_surfaces/design_surface \
  examples/glwindow/interpolated_curves \
  examples/3d/draw_space_filling_curve \
  examples/vrml/many2vrml \
  examples/vrml/test_blender_exported_hierarchy \
  examples/vrml/tools/gen_light_map \
  examples/vrml/tools/md3tovrmlsequence \
  examples/vrml/tools/xmlportals_to_x3d \
  examples/vrml/direct_vrmlglscene_test_1 \
  examples/vrml/direct_vrmlglscene_test_2 \
  examples/vrml/demo_animation \
  examples/vrml/fog_culling \
  examples/vrml/shadow_volume_test/shadow_volume_test \
  examples/vrml/bump_mapping/bump_mapping \
  examples/vrml/radiance_transfer/radiance_transfer \
  examples/vrml/radiance_transfer/precompute_radiance_transfer \
  examples/vrml/radiance_transfer/show_sh \
  examples/vrml/plane_mirror_and_shadow \
  examples/vrml/change_vrml_by_code \
  examples/vrml/change_vrml_by_code_2 \
  examples/vrml/vrml_browser_script_compiled \
  examples/vrml/simplest_vrml_browser \
  examples/vrml/simplest_vrml_browser_with_shadows \
  examples/vrml/shadow_fields/precompute_shadow_field \
  examples/vrml/shadow_fields/shadow_fields \
  examples/vrml/dynamic_ambient_occlusion/dynamic_ambient_occlusion \
  examples/vrml/gl_primitive_performance \
  examples/vrml/terrain/terrain \
  examples/vrml/scene_manager_demos \
  examples/vrml/scene_manager_basic

EXAMPLES_UNIX_EXECUTABLES := $(EXAMPLES_BASE_NAMES) \
  examples/audio/test_al_source_allocator \
  examples/lazarus/vrml_browser/vrml_browser \
  examples/lazarus/vrml_with_2d_controls/vrml_with_2d_controls \
  examples/lazarus/camera/camera

EXAMPLES_WINDOWS_EXECUTABLES := $(addsuffix .exe,$(EXAMPLES_BASE_NAMES)) \
  examples/audio/test_al_source_allocator.exe \
  examples/lazarus/vrml_browser/vrml_browser.exe \
  examples/lazarus/vrml_with_2d_controls/vrml_with_2d_controls.exe  \
  examples/lazarus/camera/camera.exe

.PHONY: examples
examples:
	$(foreach NAME,$(EXAMPLES_BASE_NAMES),$(NAME)_compile.sh && ) true

.PHONY: examples-ignore-errors
examples-ignore-errors:
	$(foreach NAME,$(EXAMPLES_BASE_NAMES),$(NAME)_compile.sh ; ) true

.PHONY: cleanexamples
cleanexamples:
	rm -f $(EXAMPLES_UNIX_EXECUTABLES) $(EXAMPLES_WINDOWS_EXECUTABLES)

# information ------------------------------------------------------------

.PHONY: info

info:
	@echo "All available units subdirectories (they are also targets"
	@echo "for this Makefile):"
	@echo $(UNITS_SUBDIRECTORIES)

# cleaning ------------------------------------------------------------

.PHONY: clean cleanmore cleanall

clean: cleanexamples
	find . -type f '(' -iname '*.ow'  -or -iname '*.ppw' -or -iname '*.aw' -or \
	                   -iname '*.o'   -or -iname '*.ppu' -or -iname '*.a' -or \
			   -iname '*.compiled' -or \
	                   -iname '*.dcu' -or -iname '*.dpu' ')' \
	     -print \
	     | xargs rm -f
	rm -Rf packages/lib/ \
	  packages/kambi_base.pas \
	  packages/kambi_glwindow.pas \
	  packages/kambi_components.pas \
	  tests/test_kambi_units tests/test_kambi_units.exe
# fpmake binary, and units/ produced by fpmake compilation
	rm -Rf fpmake units/
	$(MAKE) -C doc/pasdoc/ clean

cleanmore: clean
	find . -type f '(' -iname '*~' -or \
	                   -iname '*.bak' -or \
	                   -iname '*.~???' -or \
			   -iname '*.blend1' \
			')' -exec rm -f '{}' ';'

cleanall: cleanmore clean_container_units

# Clean compiled versions of GLWindow unit.
# Makes sure that unit GLWindow will be *always* *rebuild* in next compilation.
#
# This is useful, since GLWindow unit may be compiled with various
# back-ends (e.g. under Unices two most useful back-ends
# are XLIB and GTK). To make sure that compilation of some program
# will produce exactly what you need, it's useful to force rebuild of GLWindow.
#
# Of course this means that compilation time will suffer a little,
# since GLWindow unit will be possibly rebuild without any real need.
clean-glwindow:
	rm -f src/glwindow/glwindow.o \
	      src/glwindow/glwindow.ppu \
	      src/glwindow/GLWindow.o \
	      src/glwindow/GLWindow.ppu

# ----------------------------------------
# Set SVN tag.

svntag:
	source ../www/scripts/update_archives/generated_versions.sh && \
	  svn copy https://vrmlengine.svn.sourceforge.net/svnroot/vrmlengine/trunk/kambi_vrml_game_engine \
	           https://vrmlengine.svn.sourceforge.net/svnroot/vrmlengine/tags/kambi_vrml_game_engine/"$$GENERATED_VERSION_KAMBI_VRML_GAME_ENGINE" \
	  -m "Tagging the $$GENERATED_VERSION_KAMBI_VRML_GAME_ENGINE version of 'Kambi VRML game engine'."

# eof ------------------------------------------------------------
