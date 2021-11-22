  # this makefile will be used for build Insel user blocks from vs code

  sourcesF := $(wildcard *.f)
  sourcesF90 := $(wildcard *.f90)
  sourcesC := $(wildcard *.cpp)
  objectsF := $(patsubst %.f,%.o,$(sourcesF))
  objectsF90 := $(patsubst %.f90,%.o,$(sourcesF90))
  objectsC := $(patsubst %.cpp,%.o,$(sourcesC))
  objects := $(patsubst ../src%,.%,$(objectsF)) $(patsubst ../src%,.%,$(objectsF90)) $(patsubst ../src%,.%,$(objectsC))

  MODULE = libInselUB
  EXTENSION =
  ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...  
    ARCHITECTURE = Windows
    SHARED_EXTENSION = .dll
    BUILDING_PATH = '$(HOMEPATH)\Documents\insel.work\inselUB\resources\''
    FC = g++
    CC = g++
    L = g++
    LDL = -lgfortran
    RM = del
    CRLF = echo.		
    ifneq ($(PROCESSOR_ARCHITECTURE),x86) # is Windows x64
      PROCESSOR = x64    
      FCFLAGS = -c -m64 -O0 -Wall -fno-automatic -fno-underscoring -fmessage-length=0
      CCFLAGS = -O0 -Wall -m64 -c -fmessage-length=0
      LFLAGS = -shared -Wall -m64 -lInselTools -L"$(INSEL_HOME)"
    else #is Windows x86    
      PROCESSOR = x86    
      FCFLAGS = -c -O0 -Wall -fno-automatic -fno-underscoring -fmessage-length=0
      CCFLAGS = -O0 -Wall -c -fmessage-length=0
      LFLAGS = -shared -Wall -lInselTools -L'$(INSEL_HOME)'
    endif
  else 
  ifeq ($(shell arch)$(shell uname),x86_64Linux) # is Linux x64  
    INSEL_HOME = /usr/local/insel
    RUNTIME_HOME = $(INSEL_HOME)/insel_gui/lib/runtime/bin/
    JAR_HOME = $(INSEL_HOME)/insel_gui/lib/app/
    CUSTOM_TYPES_HOME = ${HOME}/.insel/customTypes/
    CRLF = echo \
 		
    ARCHITECTURE = 'Linux'
    PROCESSOR = 'x64'
    SHARED_EXTENSION = .so
    BUILDING_PATH = ${HOME}/Documents/insel.work/inselUB/resources/
    MODULE = libInselUB
    FC = g++
    CC = g++
    L = g++
    FCFLAGS = -c -m64 -fPIC -O0 -Wall -fno-automatic -fno-underscoring -fmessage-length=0 -std=legacy -Wno-intrinsic-shadow
    CCFLAGS = -m64 -c -O0 -Wall -fmessage-length=0 -fPIC
    LFLAGS = -lInselTools -ldl -m64 -shared
    RM = rm -f
  else 
  ifeq ($(shell arch)$(shell uname),i386Linux)  #is Linux x86     
    ARCHITECTURE = 'Linux'
    PROCESSOR = 'x86'
    SHARED_EXTENSION = .so
    BUILDING_PATH = ${HOME}/Documents/insel.work/inselUB/resources/
    MODULE = libInselUB
    FC = g++
    CC = g++
    L = g++
    FCFLAGS = -c -fPIC -O0 -Wall -fno-automatic -fno-underscoring -fmessage-length=0
    CCFLAGS = -c -fPIC -O0 -Wall -fmessage-length=0
    LFLAGS = -shared libInselTools.so -ldl
    RM = rm -f

  else  #is MacOS
    CP = ln -sf 
    ARCHITECTURE =  'MacOS'
    PROCESSOR = 'x64'
    SHARED_EXTENSION = .dylib
    BUILDING_PATH = ../inselDeployment/Build/MacOS/
    FC = g++
    CC = g++
    L = g++
    FCFLAGS = -c -O0 -Wall -fno-automatic -fno-underscoring -fmessage-length=0
    CCFLAGS = -O0 -Wall -m64 -c -fmessage-length=0 
    LFLAGS = -L. -linselTools -dynamiclib -o$(BUILDING_PATH)$(MODULE)$(SHARED_EXTENSION)
    RM = rm -f
  endif
  endif
  endif

  all:
		@echo Compile user blocks for $(ARCHITECTURE) $(PROCESSOR)
    ifneq ($(sourcesF),)
			@$(FC) $(FCFLAGS) $(sourcesF)
			@$(CRLF)
			@echo Fortran user blocks:			
			@echo $(foreach file, $(sourcesF), $(basename $(file)))
    endif
    ifneq ($(sourcesF90),)
			@$(FC) $(FCFLAGS) $(sourcesF90)
			@$(CRLF)
			@echo Fortran90 user blocks:			
			@echo $(foreach file, $(sourcesF90), $(basename $(file)))
    endif
    ifneq ($(sourcesC),)
			$(CC) $(CCFLAGS) -I /usr/include/eigen3/ $(sourcesC)
			@$(CRLF)
			@echo C user blocks:    			
			@echo $(foreach file, $(sourcesC), $(basename $(file)))
    endif		
		@$(foreach file, $(objects),$(L) $(LFLAGS) -o"$(subst ',,$(BUILDING_PATH))$(basename $(file))$(SHARED_EXTENSION)" $(file) $(LDL) && )  $(CRLF)
		@echo User blocks Link completed		
    ifneq ($(wildcard $(RUNTIME_HOME)/.*),)			
			@$(foreach file, $(objects), $(RUNTIME_HOME)javac -proc:none -classpath '$(JAR_HOME)*' -d '$(CUSTOM_TYPES_HOME)' './$(basename $(file)).java' && ) $(CRLF)
			@echo Java classes:
			@echo $(foreach file, $(objects), $(basename $(file)))   
    endif
		@$(foreach file, $(objects),$(L) $(LFLAGS) -o"$(subst ',,$(BUILDING_PATH))$(basename $(file))$(SHARED_EXTENSION)" $(file) $(LDL) && )  $(CRLF)
		@echo User blocks Link completed				
		@$(RM) *.o   
  clean:
		@$(RM) *.o
		@$(RM) $(BUILDING_PATH)$(MODULE)$(SHARED_EXTENSION)