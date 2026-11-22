unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps;
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 1.00.970 (+30)
//## Items.................... 1
//## Last Updated ............ 22nov2026, 21nov2026, 22sep2022
//## Lines of Code............ 2,100+
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tapp                   | tbasicapp         | 1.00.940  | 21nov2026   | Basic music player - 21nov2026, 22sep2022
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy          :boolean=false;
   iapp                :tobject=nil;

const

   //app -----------------------------------------------------------------------
   col_lvol           =0;
   col_nav            =1;
   col_info           =2;
   col_rvol           =3;

   col_volWidth       =40;
   col_navWidth       =600;
   col_infoWidth      =400;




type

{tapp}
   tapp=class(tbasicapp)
   private

    ibarleft          :tbasiccontrol;
    ibarright         :tbasiccontrol;
    ilastl            :single;
    ilastr            :single;
    ivol              :tsimpleint;
    iplaylist         :tplaylist;
    imode             :tbasicsel;
    iformats          :tbasicset;
    ijump             :tbasicjump;
    ititlebar         :tbasictoolbar;
    ijumptitle        :tbasictoolbar;
    ilistcap          :tbasictoolbar;
    inavcap           :tbasictoolbar;
    inav              :tbasicnav;
    ilist             :tbasicmenu;
    iinfo             :tbasicmenu;
    isettingspanel    :tbasicscroll;
    ilistroot         :tbasicscroll;
    ishowbars         :boolean;
    ishownav          :boolean;
    ishowsettings     :boolean;
    ishowinfo         :boolean;
    ishowlistlinks    :boolean;
    ionacceptonce     :boolean;
    ilargejumptitle   :boolean;
    ilargejump        :boolean;
    iautoplay         :boolean;
    imuststop         :boolean;
    imustplay         :boolean;
    iplaying          :boolean;
    ibuildingcontrol  :boolean;
    iloaded           :boolean;
    ilasttimeref      :longint64;
    iflashref         :longint64;
    itimer100         :longint64;
    itimer350         :longint64;
    itimer500         :longint64;
    itimerslow        :longint64;
    iinfotimer        :longint64;
    ifasttimer        :longint64;
    iplaylistREF      :string;
    ijumpcap          :string;
    iinforef          :string;
    ilasterror        :string;
    ilastsavefilename :string;
    ilastfilename     :string;
    inavref           :string;
    isettingsref      :string;
    ilastpos          :longint32;
    imustpos          :longint32;
    imustpertpos      :double;

    //.status support
    iff               :longint32;
    iintro            :longint32;
    iinfoid           :longint32;
    iselstart         :longint32;
    iselcount         :longint32;
    idownindex        :longint32;
    inavindex         :longint32;
    ifolderindex      :longint32;
    ifileindex        :longint32;
    inavcount         :longint32;
    ifoldercount      :longint32;
    ifilecount        :longint32;
    iisnav            :boolean;
    iisfolder         :boolean;
    iisfile           :boolean;
    ijumpstatus       :longint32;

    procedure xcmd0(xcode2:string);
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    function __oninfo(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xsavesettings2(xforce:boolean);
    procedure xautosavesettings;
    procedure xfillinfo;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function  xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function  xintroms:longint;
    function  xffms:longint;
    function  xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
    function  getshowplaylist:boolean;
    procedure setshowplaylist(x:boolean);
    function  findlistcmd(n:string;var xcaption,xhelp,xcmd:string;var xtep:longint;var xenabled:boolean;xextendedlables:boolean):boolean;
    function  canprev:boolean;
    function  cannext:boolean;
    function  xmustsaveplaylist:boolean;
    procedure xupdatebuttons;
    function  playlist__canaddfile:boolean;
    procedure onpaint__bar(sender:tobject);

    //.nav
    procedure nav__syncmask;

    //.saveas
    function  xlistfilename:string;
    function  xcansaveas:boolean;
    procedure xsaveas;

    //.playlist
    function  playlist__filename:string;

    //.mask
    function  mask__user:string;
    function  mask__full:string;
    function  mask__list(xfull:boolean):string;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //information
    property showplaylist:boolean read getshowplaylist write setshowplaylist;

   end;



//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function app__syncandsavesettings:boolean;


implementation

{$ifdef gui}
uses
    gossdat;
{$endif}



//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1500'
else if (xname='height')              then result:='980'

else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde - 31jan2026
else if (xname='msstore.name')        then result:='BlaizMusicPlayer'//optional - overrides default name for Clyde - 15apr2026


else if (xname='ver')                 then result:='1.00.970'
else if (xname='date')                then result:='22nov2026'
else if (xname='name')                then result:='Music Player'
else if (xname='web.name')            then result:='musicplayer'//used for website name
else if (xname='des')                 then result:='Play offline music files from a folder or playlist'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2026)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

//.special options -------------------------------------------------------------

//else if (xname='back.name')           then result:='Gradient Purple (Scrolling)'//default background name

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
//reserved
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);

except;end;
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure m32(const sm:array of byte);//mono only
   begin

   tep__32( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure c(const sc:array of byte);//color only
   begin

   tep__20( xindex ,[0] ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m6(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle6 ,it_img32 );

   end;

begin

{
case xindex of
tepScrollDown20       :m( mtep_ScrollDown20    );
end;//case
{}

end;

function app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try

//lock check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;

except;end;

//unlock
itimerbusy:=false;

end;



//## tapp ######################################################################

constructor tapp.create;
const
   vsep               =5;

var
   p                  :longint32;
   e                  :string;
   str1               :string;

   procedure ladd(n:string);
   var
      xcaption        :string;
      xhelp           :string;
      xcmd            :string;
      xtep            :longint32;
      xenabled        :boolean;

   begin

   //check
   if (ilistcap=nil) then exit;

   if not findlistcmd(n,xcaption,xhelp,xcmd,xtep,xenabled,false) then
      begin

      showerror('List command not found "'+n+'"');
      exit;

      end;

   //get
   ilistcap.add(xcaption,xtep,0,xcmd,'Playlist|'+xhelp);

   end;

begin


if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy

//win__make_gosswin2_pas;app__halt;

app__closepaused      :=true;//app is in charge of shutdown persmission

need_mm( false );//required

//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));

//init
ibuildingcontrol      :=true;

timer__init( itimer100  );
timer__init( itimer350  );
timer__init( itimer500  );
timer__init( itimerslow );
timer__init( iflashref  );
timer__init( iinfotimer );
timer__init( ifasttimer );

ilasttimeref          :=0;

//vars
iloaded               :=false;
ilastsavefilename     :='';
ishowlistlinks        :=false;
ionacceptonce         :=false;
ilasterror            :='';
inavref               :='';
ilargejump            :=false;
ilargejumptitle       :=false;
iautoplay             :=false;
ijumpstatus           :=0;//off
ishowbars             :=false;
ishownav              :=false;
ishowinfo             :=false;
ishowsettings         :=false;
iintro                :=0;
iff                   :=0;
iplaylistREF          :='';
ilastl                :=0;
ilastr                :=0;

mm_playmanagement_init(imuststop,imustplay,iplaying,imustpertpos,imustpos,ilastpos,ilastfilename);

//.playlist handler
iplaylist             :=tplaylist.create;
iplaylist.fullmask    :=mask__full;//master mask - 21nov2026, 20mar2022
iplaylist.partmask    :='';

//controls
with rootwin do
begin

scroll                :=false;
xhead;
xgrad;

with xhead do
begin

add('Nav',tepNav20,0,'nav.toggle','Navigation Panel | Toggle navigation panel (play folder / play list)');
add('Play Folder',tepFolder20,0,'show.folder','Play music from a folder');
add('Play List',tepNotes20,0,'show.list','Play music from a playlist');
//xhead.addsep;
add('Prev',tepPrev20,0,'prev','Previous file');
add('Rewind',tepRewind20,0,'rewind','Rewind # seconds');
add('Stop',tepStop20,0,'stop','Stop playback');
benabled2['stop']     :=false;

add('Play',tepPlay20,0,'play','Toggle playback');
add('Fast Forward',tepFastForward20,0,'fastforward','Fast forward # seconds');
add('Next',tepNext20,0,'next','Next file');
add('Menu',tepMenu20,0,'menu','Show menu');

xaddMixer;
xaddoptions;
xaddhelp;

end;//xhead

//.playback status
with xhigh2 do
begin

ijumpcap              :='Playback Progress';
ijumptitle            :=ntitlebar(false,ijumpcap,'Music playback progress');

with ijumptitle do
begin

osepv                 :=5;
oautoheight           :=false;//1 line only
halign                :=2;

add('Nav',tepNav20,0,'nav.toggle','Navigation Panel | Toggle navigation panel (play folder / play list)');
add('Bars',tepVisual20,0,'bars.toggle','Volume Bars | Toggle volume bars');
add('Info',tepInfo20,0,'info.toggle','Information Panel | Toggle information panel');
add('Settings',tepSettings20,0,'settings.toggle','Information Panel | Toggle settings sub-panel');
add('',tepDown,0,'jump.menu','Playback Progress|Show options');

end;

ijump                 :=xhigh2.njump('','Click and/or drag to adjust playback position',0,0);

end;//xhigh2

end;


//------------------------------------------------------------------------------
//navigation column - left -----------------------------------------------------
//------------------------------------------------------------------------------

rootwin.xcols.style   :=bcLefttoright;//04feb2025

with rootwin.xcols.makecol( col_nav ,col_navWidth ,false ) do
begin

ilistroot             :=client as tbasicscroll;

//.play from folder
inavcap               :=ntoolbar('Navigate files and folders on disk');

with inavcap do
begin

maketitle3('Play Folder',false,false);
opagename             :='folder';
normal                :=false;

add('Refresh',tepRefresh20,0,'refresh','Navigation|Refresh list');
add('Fav',tepFav20,0,'nav.fav','Navigation|Show favourites list');
add('Back',tepBack20,0,'nav.prev','Navigation|Previous folder');
add('Forward',tepForw20,0,'nav.next','Navigation|Next folder');
add('Add',tepEdit20,0,'list.addfile','Playlist|Add selected file to playlist');

end;

inav                  :=nnav.makenavlist;
inav.hisname          :='musicplayer';
inav.omasklist        :=mask__full;
inav.oautoheight      :=true;
inav.sortstyle        :=nlName;//nlSize;
inav.style            :=bnNavlist;
inav.ofindname        :=true;//21feb2022
inav.opagename        :='folder';

//.play from list
ilistcap              :=ntoolbar('Navigate files and folders on disk');

with ilistcap do
begin

maketitle3('Play List',false,false);
opagename             :='list';
normal                :=false;
ladd('edit');
ladd('new');
ladd('open');
ladd('save as');
addsep;
ladd('cut');
ladd('copy');
ladd('copy all');
ladd('paste');
ladd('replace');//19apr2022
ladd('undo');

end;

with xhigh2 do
begin

imode                 :=nsel('Playback Mode','Playback mode',0);

with imode do
begin

xadd('Once','once','Playback Mode|Play selected once');
xadd('Repeat One','repeat1','Playback Mode|Play selected repeatedly');
xadd('Repeat All','repeat1','Playback Mode|Play all repeatedly');
xadd('All Once','once','Playback Mode|Play all once');
xadd('Random','repeat1','Playback Mode|Play randomly');

end;

end;

ilist                 :=nlist('','',nil,0);
ilist.opagename       :='list';
ilist.oretainpos      :=true;
ilist.onumberfrom     :=0;
ilist.help            :='Select file to play';
ilist.ocanshowmenu    :=true;

//default playback list style
page                  :='folder';

end;


//------------------------------------------------------------------------------
//information column - right ---------------------------------------------------
//------------------------------------------------------------------------------

with rootwin.xcols.makecol( col_info ,col_infoWidth ,false ) do
begin

ititlebar             :=ntitlebar(false,'Music Information','Music information');

with ititlebar do
begin

add('',tepLess20,0,'vol.dn','Volume|Decrease volume');
add('Vol 100',tepNone,0,'vol.100','Volume|Reset volume to 100%');
add('',tepMore20,0,'vol.up','Volume|Increase volume');

end;

iinfo                 :=nlistx('','Music playback information',19,19,__oninfo);//07sep2025, 11aug2025
iinfo.otab            :=tbL100_L500;
iinfo.oscaleh         :=0.95;
iinfo.makepanel;//21aug2025

//settings
isettingspanel        :=xhigh2;
isettingspanel.ntitle(false,'Settings','Settings');
isettingspanel.osepv  :=5;

//.formats

with xhigh2.ncols do
begin

makeautoheight;

iformats              :=makecol(0,30,false).nset('File Types','File Types | Select music file types to list in the Navigation panel (left) | Selecting no file type lists all music file types',7,7);

with iformats do
begin

osepv                 :=vsep;
itemsperline          :=8;

for p:=0 to max32 do
begin

if mm_ext( p ,str1 ) then xset( p ,str1  ,str1  ,'File Types|Include ".'+str1+'" file type in play list',true)
else                      break;

end;//p

end;//iformats

//.volume
ivol                  :=xhigh2.mwavevol('','');
ivol.osepv            :=vsep;

end;

end;


//------------------------------------------------------------------------------
//effects bars -----------------------------------------------------------------
//------------------------------------------------------------------------------

with rootwin.xcols.makecol( col_lvol ,col_volWidth ,false ) do
begin

ibarleft    :=client;
oroundstyle :=corSlight;
normal      :=false;
onpaint     :=onpaint__bar;

end;

with rootwin.xcols.makecol( col_rvol ,col_volWidth ,false ) do
begin

ibarright   :=client;
oroundstyle :=corSlight;
normal      :=false;
onpaint     :=onpaint__bar;

end;



//events
rootwin.onaccept                :=xonaccept;
rootwin.xhead.onclick           :=__onclick;
ijumptitle.onclick              :=__onclick;
ititlebar.onclick               :=__onclick;

//.nav
inavcap.onclick                 :=__onclick;
inav.onclick                    :=__onclick;
inav.xlist.showmenuFill1        :=xshowmenuFill1;
inav.xlist.showmenuClick1       :=xshowmenuClick1;
//.list
ilistcap.onclick                :=__onclick;
ilist.onclick                   :=__onclick;
ilist.showmenuFill1             :=xshowmenuFill1;
ilist.showmenuClick1            :=xshowmenuClick1;
iplaylist.list                  :=ilist;//connect playlist handler to user list - 20mar2022



//.jump
ijump.onclick                   :=__onclick;

//animated icon support - 30apr2022
rootwin.xhead.aniAdd(tepIcon24,500);
rootwin.xhead.aniAdd(tepIcon24B,500);
//rootwin.xhead.aniAdd(tepError32,500);


//defaults
ibuildingcontrol                :=false;
xloadsettings;
xfillinfo;


//iautoplay
if iautoplay then imustplay     :=true;

//finish
createfinish;

end;

destructor tapp.destroy;
begin
try

//settings
xsavesettings;

//stop
mm_stop;

//controls
freeobj(@iplaylist);

//self
inherited destroy;

except;end;
end;

procedure tapp.xupdatebuttons;
var
   xmustalign,xshownav,xplaylist,bol1:boolean;
   xvollevel:longint;
begin
try
//init
xmustalign :=false;
xshownav   :=ishownav or (not ishowinfo);
xvollevel  :=ivol.val;

//get
xplaylist:=showplaylist;
bol1:=ishowlistlinks;
rootwin.xhead.bmarked2['show.folder']:=not xplaylist;
rootwin.xhead.bmarked2['show.list']:=xplaylist;

ilistcap.benabled2['list.undo']:=iplaylist.canundo;
ilistcap.benabled2['list.open']:=iplaylist.canopen;
ilistcap.benabled2['list.saveas']:=iplaylist.cansave;
ilistcap.benabled2['list.new']:=iplaylist.cannew;
ilistcap.benabled2['list.cut']:=iplaylist.cancut;
ilistcap.benabled2['list.copy']:=iplaylist.cancopy;
ilistcap.benabled2['list.copyall']:=iplaylist.cancopyall;

ilistcap.bvisible2['list.undo']:=bol1;
ilistcap.bvisible2['list.open']:=bol1;
ilistcap.bvisible2['list.saveas']:=bol1;
ilistcap.bvisible2['list.new']:=bol1;
ilistcap.bvisible2['list.cut']:=bol1;
ilistcap.bvisible2['list.copy']:=bol1;
ilistcap.bvisible2['list.copyall']:=bol1;
ilistcap.bvisible2['list.replace']:=bol1;//19apr2022

inavcap.benabled2['list.addfile']:=playlist__canaddfile;//19aug2025

ititlebar.benabled2['vol.up']   :=(xvollevel<ivol.max);
ititlebar.benabled2['vol.100']  :=(xvollevel<>100);
ititlebar.benabled2['vol.dn']   :=(xvollevel>ivol.min);

with ijumptitle do
begin

bmarked2['nav.toggle']          :=xshownav;
bmarked2['info.toggle']         :=ishowinfo;
bmarked2['settings.toggle']     :=ishowsettings;
bmarked2['bars.toggle']         :=ishowbars;

end;

with inavcap do
begin

benabled2['nav.prev']           :=inav.canprev;
benabled2['nav.next']           :=inav.cannext;

end;

//play
bol1                            :=iplaying;//playing;

with rootwin.xhead do
begin

benabled2['rewind']             :=(mm_pos>1);
benabled2['stop']               :=bol1;
bflash2['play']                 :=bol1;
bmarked2['play']                :=bol1;
benabled2['fastforward']        :=(mm_len<>0);
benabled2['prev']               :=canprev;//23mar2022
benabled2['next']               :=cannext;
bmarked2['nav.toggle']          :=xshownav;

end;

//.show columns
rootwin.xcols.vis[ col_lvol ]   :=ishowbars;
rootwin.xcols.vis[ col_nav  ]   :=xshownav;
rootwin.xcols.vis[ col_info ]   :=ishowinfo;
rootwin.xcols.vis[ col_rvol ]   :=ishowbars;

if (isettingspanel.visible<>ishowsettings) then//15aug2025
   begin

   isettingspanel.visible       :=ishowsettings;
   xmustalign                   :=true;

   end;

//.jump
ijump.status                    :=ijumpstatus;
ijump.olarge                    :=ilargejump;
ijumptitle.olarge               :=ilargejumptitle;

//.xmustalign
if xmustalign then gui.fullalignpaint;

except;end;
end;

function tapp.findlistcmd(n:string;var xcaption,xhelp,xcmd:string;var xtep:longint;var xenabled:boolean;xextendedlables:boolean):boolean;
var
   str1:string;

   procedure xset(acap,ahelp,acmd:string;atep:longint;aenabled:boolean);
   begin
   xcaption:=acap;
   xhelp:=ahelp;
   xcmd:=acmd;
   xtep:=atep;
   xenabled:=aenabled;
   result:=true;
   end;
begin
//defaults
result:=false;

try
n:=strlow(n);
xcaption:='';
xhelp:='';
xcmd:='';
xtep:=tepNone;
xenabled:=false;
str1:=insstr('...',xextendedlables);
//get
if (n='new')           then xset('New'+str1,'Create new playlist','list.new',tepNew20,iplaylist.cannew)
else if (n='edit')     then xset('Edit','Show edit menu','list.edit',tepEdit20,true)
else if (n='open')     then xset('Open'+str1,'Open playlist from file','list.open',tepOpen20,iplaylist.canopen)
else if (n='save as')  then xset('Save As'+str1,'Save playlist to file','list.saveas',tepSave20,iplaylist.cansave)
else if (n='cut')      then xset('Cut','Cut selected playlist item to Clipboard','list.cut',tepCut20,iplaylist.cancut)
else if (n='copy')     then xset('Copy','Copy selected playlist item to Clipboard','list.copy',tepCopy20,iplaylist.cancopy)
else if (n='copy all') then xset('Copy All','Copy entire playlist to Clipboard','list.copyall',tepCopy20,iplaylist.cancopyall)
else if (n='paste')    then xset('Paste','Paste playlist from Clipboard at end of current playlist','list.paste',tepPaste20,iplaylist.canpaste)
else if (n='replace')  then xset('Replace','Replace playlist with Clipboard playlist','list.replace',tepPaste20,iplaylist.canreplace)
else if (n='undo')     then xset('Undo','Undo last playlist change','list.undo',tepUndo20,iplaylist.canundo);
except;end;
end;

function tapp.playlist__canaddfile:boolean;
begin
result:=(not showplaylist) and (inav.valuestyle=nltFile);
end;

function tapp.getshowplaylist:boolean;
begin
result:=(ilistroot<>nil) and (ilistcap<>nil) and strmatch(ilistroot.page,ilistcap.opagename);
end;

procedure tapp.setshowplaylist(x:boolean);
begin
if (ilistroot<>nil) and (ilistcap<>nil) then ilistroot.page:=low__aorbstr(inavcap.opagename,ilistcap.opagename,x);
end;

function tapp.xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
begin
result:=true;

try

if io__fileexists(xfilename) then
   begin

   if not ionacceptonce then
      begin

      ionacceptonce   :=true;

      iplaylist.xfillundo;//fill undo

      showplaylist    :=true;//switch to play list mode - 20mar2022

      end;

   iplaylist.xaddone(-1,'',xfilename);

   end;

if ionacceptonce and (xindex>=pred(xcount)) then iplaylist.xmask(true);

//reset
if (xindex>=pred(xcount)) then ionacceptonce:=false;//done

except;end;
end;

function tapp.xintroms:longint;
begin

case iintro of

1:result:=2000;
2:result:=5000;
3:result:=10000;
4:result:=30000;
else result:=0;

end;//case

end;

function tapp.xffms:longint;
begin
case iff of
1:result:=2000;
2:result:=5000;
3:result:=10000;
4:result:=30000;
else result:=1000;
end;
end;

procedure tapp.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
label
   skipend;
var
   p,xholdindex,xholdms:longint;

   procedure ladd(n:string);
   var
      xcaption,xhelp,xcmd:string;
      xtep:longint;
      xenabled:boolean;
   begin
   //check
   if (ilistcap=nil) then exit;
   if not findlistcmd(n,xcaption,xhelp,xcmd,xtep,xenabled,true) then
      begin
      showerror('List command not found "'+n+'"');
      exit;
      end;
   //get
   low__menuitem2(xmenudata,xtep,xcaption,xhelp,xcmd,100,aknone,xenabled);
   end;

   function ides(xsec:longint):string;
   begin
   case xsec of
   0:result:='Select to play entire midi (no intro mode)';
   else result:='Select to play first '+intstr32(xsec)+' seconds of midi';
   end;//case
   end;

   function fdes(xsec:longint):string;
   begin
   result:='Select to rewind and fast forward by '+intstr32(xsec)+' second'+insstr('s',xsec>=2);
   end;

begin
try
//check
if zznil(xmenudata,5000) then exit;

//menu history
xmenuname:='history.'+xstyle;


//main options
if (xstyle='') then
   begin
   low__menutitle(xmenudata,tepnone,'Play Options','Play options');
   if not showplaylist then low__menuitem2(xmenudata,tepRefresh20,'Refresh','Refresh list','refresh',100,aknone,true);
   low__menuitem2(xmenudata,tepStop20,'Stop','Stop playback','stop',100,aknone,iplaying);
   low__menuitem3(xmenudata,tepPlay20,'Play','Toggle playback','play',100,aknone,iplaying,true);
   low__menusep(xmenudata);
   low__menuitem3(xmenudata,tep__yes(iautoplay),'Play on Start','Ticked: Commence play on program start','autoplay',100,aknone,false,true);
   //.save as
   low__menuitem3(xmenudata,tepSave20,'Save As...','Save selected item to file','saveas',100,aknone,false,xcansaveas);

   //.intro
   low__menutitle(xmenudata,tepnone,'Intro Mode','Play first # seconds of midi');
   low__menuitem3(xmenudata,tep__tick(iintro=0),'Off',ides(0),'intro:0',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=1),'2 secs',ides(2),'intro:1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=2),'5 secs',ides(5),'intro:2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=3),'10 secs',ides(10),'intro:3',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=4),'30 secs',ides(30),'intro:4',100,aknone,false,true);
   //.ff and rr time
   low__menutitle(xmenudata,tepnone,'Rewind / Fast Forward By','Rewind / Fast Forward by # seconds');
   low__menuitem3(xmenudata,tep__tick(iff=0),'1 sec',fdes(1),'ff:0',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=1),'2 secs',fdes(2),'ff:1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=2),'5 secs',fdes(5),'ff:2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=3),'10 secs',fdes(10),'ff:3',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=4),'30 secs',fdes(30),'ff:4',100,aknone,false,true);
   end
else if (xstyle='jump.menu') then
   begin
   low__menutitle(xmenudata,tepnone,'Playback Progress Bar','Playback progress bar options');
   low__menuitem3(xmenudata,tep__yes(ilargejumptitle),'Large Title','Ticked: Show large title/lyrics','largejumptitle',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(ilargejump),'Large Bar','Ticked: Show large playback progress bar','largejump',100,aknone,false,true);

   low__menutitle(xmenudata,tepnone,'Status','Playback progress bar status');
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=1),'Elapsed Time','Selected: Show elapsed time in playback progress bar','jumpstatus.1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=2),'Remaining Time','Selected: Show remaining time in playback progress bar','jumpstatus.2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=0),'Off','Selected: Show no status in playback progress bar','jumpstatus.0',100,aknone,false,true);

   goto skipend;

   end;

//play list options
if showplaylist or (xstyle='playlist') then
   begin
   low__menutitle(xmenudata,tepNotes20,'Play List Options','Play List options');
   ladd('new');
   ladd('open');
   ladd('save as');
   low__menusep(xmenudata);
   ladd('cut');
   ladd('copy');
   ladd('copy all');
   ladd('paste');
   ladd('replace');
   ladd('undo');
   low__menusep(xmenudata);
   low__menuitem3(xmenudata,tep__yes(ishowlistlinks),'Show Links on Toolbar','Ticked: Show links on toolbar','list.showlinks',100,aknone,false,true);
   end;

skipend:
except;end;
end;

function tapp.xlistfilename:string;
begin
if       showplaylist             then result:=ilist.xgetval2(ilist.itemindex)
else if (inav.valuestyle=nltFile) then result:=inav.value
else                                   result:='';
end;

function tapp.xcansaveas:boolean;
begin
result:=(xlistfilename<>'');
end;

procedure tapp.xsaveas;
var
   str1               :string;
   sf                 :string;
   df                 :string;
   dext               :string;
   e                  :string;

begin

//init
sf                    :=xlistfilename;
df                    :=io__extractfilepath(strdefb(ilastsavefilename,sf))+io__extractfilename(sf);
dext                  :=io__readfileext_low(df);
str1                  :='';

//get
if gui.popsave( df ,dext ,'' ,str1 ) then
   begin

   ilastsavefilename  :=df;

   if not io__copyfile(sf,df,e) then gui.poperror('',e);

   end;

end;

function tapp.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
if strmatch(strcopy1(xcode2,1,4),'nav.') then result:=false
else
   begin
   result:=true;//handled
   xcmd(nil,0,xcode2);
   end;
end;

procedure tapp.xfillinfo;
begin

case showplaylist of

true:iisfile:=(ilastfilename<>'')
else if zzok(inav,7320) then inav.findinfo(iselstart,iselcount,idownindex,inavindex,ifolderindex,ifileindex,inavcount,ifoldercount,ifilecount,iisnav,iisfolder,iisfile);

end;//case

low__iroll(iinfoid,1);

end;

function tapp.playlist__filename:string;
begin

result                :=io__settingsfolder + 'playlist.m3u';

end;

function tapp.mask__user:string;
begin

result                :=mask__list( false );

end;

function tapp.mask__full:string;
begin

result                :=mask__list( true );

end;

function tapp.mask__list(xfull:boolean):string;
label
   redo;

var
   p                  :longint32;
   v                  :string;
   xonce              :boolean;

   procedure s(const v:string);
   begin

   if (v<>'') then
      begin

      result          :=result + '*.' + v + ';' ;

      end;

   end;

begin

//defaults
result                :='';

//get
redo:

for p:=0 to max32 do
begin

case mm_ext( p ,v ) of

true:if xfull or iformats.vals[p] then s( v );
else break;

end;//case

end;//p

//check
if (result='') and (not xfull) then
   begin

   xfull              :=true;

   goto redo;

   end;

end;

procedure tapp.nav__syncmask;
var
   v:string;

begin

v                     :=mask__user;

if (v<>inav.omasklist) then
   begin

   inav.omasklist:=v;

   end;
   
end;

procedure tapp.xloadsettings;
var
   a:tvars8;
   e,xname:string;
begin
try
//defaults
a:=nil;
//check
if zznil(prgsettings,5001) then exit;
//init
a:=vnew2(950);
//filter
a.b['show.list']             :=prgsettings.bdef('show.list',false);//20mar2022
a.i['intro']                 :=prgsettings.idef('intro',0);
a.i['ff']                    :=prgsettings.idef('ff',0);//19apr2022
a.i['midvol']                :=prgsettings.idef('midvol',100);
a.b['autoplay']              :=prgsettings.bdef('autoplay',true);
a.b['autotrim']              :=prgsettings.bdef('autotrim',false);
a.b['largejump']             :=prgsettings.bdef('largejump',true);
a.b['largejumptitle']        :=prgsettings.bdef('largejumptitle',true);
a.b['lshow']                 :=prgsettings.bdef('lshow',true);
a.b['alwayson']              :=prgsettings.bdef('alwayson',false);
a.b['animateicon']           :=prgsettings.bdef('animateicon',true);//30apr2022
a.b['list.showlinks']        :=prgsettings.bdef('list.showlinks',false);//27mar2022
a.b['lshowsep']              :=prgsettings.bdef('lshowsep',false);
a.i['speed']                 :=prgsettings.idef('speed',100);
a.i['mode']                  :=prgsettings.idef('mode',2);
a.i['style']                 :=prgsettings.idef('style',0);
a.i['deviceindex']           :=prgsettings.idef('deviceindex',0);
a.i['formats']               :=prgsettings.idef('formats',max32);//all on by default - 21nov2026
a.s['folder']                :=prgsettings.sdef('folder','!:\');//sample drive
a.s['name']                  :=io__extractfilename(prgsettings.sdef('name',''));
a.s['playlist.filename']     :=prgsettings.sdef('playlist.filename','');
a.i['playlist.index']        :=prgsettings.idef('playlist.index',0);
a.b['showbars']              :=prgsettings.bdef('showbars',true);
a.b['shownav']               :=prgsettings.bdef('shownav',true);
a.b['showinfo']              :=prgsettings.bdef('showinfo',true);
a.b['showsettings']          :=prgsettings.bdef('showsettings',true);//15aug2025
a.i['jumpstatus']            :=prgsettings.idef('jumpstatus',1);

//nav
inav.xfromprg2('nav',a);//prg -> nav -> a

//get
ishowlistlinks               :=a.b['list.showlinks'];
iintro                       :=frcrange32(a.i['intro'],0,4);
iff                          :=frcrange32(a.i['ff'],0,4);//19apr2022
imode.val                    :=frcrange32(a.i['mode'],0,mmMax);
iformats.val                 :=a.i['formats'];
ishowbars                    :=a.b['showbars'];
ishownav                     :=a.b['shownav'];
ishowinfo                    :=a.b['showinfo'];
ishowsettings                :=a.b['showsettings'];
ijumpstatus                  :=frcrange32(a.i['jumpstatus'],0,2);
nav__syncmask;

xname                        :=a.s['name'];

case (xname<>'') of

true:inav.value              :=io__readportablefilename(io__asfolderNIL(a.s['folder']))+xname;//focus the previously playing track - 20feb2022
else inav.folder            :=io__readportablefilename(io__asfolderNIL(a.s['folder']));

end;//case


//.playlist
iplaylist.partmask           :=mask__user;
iplaylist.xopen2( playlist__filename ,a.i['playlist.index'] ,false ,false ,e );
xmustsaveplaylist;//don't save now we've loaded it - 25mar2022

//.other
ilargejump                   :=a.b['largejump'];
ilargejumptitle              :=a.b['largejumptitle'];
iautoplay                    :=a.b['autoplay'];//do after
showplaylist                 :=a.b['show.list'];

//sync
prgsettings.data             :=a.data;
xupdatebuttons;

except;end;

//free
freeobj(@a);

//mark as loaded
iloaded:=true;

end;

procedure tapp.xsavesettings;
begin
xsavesettings2(true);
end;

procedure tapp.xsavesettings2(xforce:boolean);
var
   a:tvars8;
   e:string;
begin
try
//check
if not iloaded then exit;
//defaults
a:=nil;
a:=vnew2(951);
//get
a.b['show.list']             :=showplaylist;//20mar2022
a.i['intro']                 :=frcrange32(iintro,0,4);
a.i['ff']                    :=frcrange32(iff,0,4);//19apr2022
a.b['largejump']             :=ilargejump;
a.b['largejumptitle']        :=ilargejumptitle;
a.b['autoplay']              :=iautoplay;
a.b['list.showlinks']        :=ishowlistlinks;
a.i['mode']                  :=imode.val;
a.i['formats']               :=iformats.val;
a.s['folder']                :=io__makeportablefilename(inav.folder);
a.s['name']                  :=io__extractfilename(inav.value);
a.b['showbars']              :=ishowbars;
a.b['shownav']               :=ishownav;
a.b['showinfo']              :=ishowinfo;
a.b['showsettings']          :=ishowsettings;
a.i['jumpstatus']            :=ijumpstatus;

a.i['playlist.index']        :=ilist.itemindex;

if xmustsaveplaylist or xforce then iplaylist.xsave2( playlist__filename ,false ,e );//21nov2026 ,25mar2022

inav.xto(inav,a,'nav');

//set
prgsettings.data             :=a.data;
siSaveprgsettings;
except;end;

//free
freeobj(@a);

end;

function tapp.xmustsaveplaylist:boolean;
begin
result:=low__setstr(iplaylistREF,intstr32(iplaylist.id));
end;

procedure tapp.xautosavesettings;
var
   str1:string;
begin
try
//check
if not iloaded then exit;
//get
str1:=
 intstr32(iplaylist.id)+'|'+intstr32(iintro)+'|'+intstr32(iff)+'|'+bolstr(ishowlistlinks)+bolstr(showplaylist)+bolstr(ishownav)+bolstr(ishowbars)+bolstr(ishowinfo)+bolstr(ilargejumptitle)+bolstr(ilargejump)+bolstr(iautoplay)+'|'+intstr32(ijumpstatus)+'|'+
 intstr32(imode.val)+'|'+intstr32(inav.sortstyle)+'|'+intstr32(iformats.val)+'|'+inav.folder;

if low__setstr(isettingsref,str1) then xsavesettings2(false);
except;end;
end;

function tapp.canprev:boolean;
begin
if showplaylist then result:=(ilist.itemindex>=1) else result:=(inav.itemindex>=1);
end;

function tapp.cannext:boolean;
begin
if showplaylist then result:=(ilist.itemindex<pred(ilist.count)) else result:=(inav.itemindex<pred(inav.totalcount));
end;

procedure tapp.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tapp.xcmd0(xcode2:string);
begin
xcmd(nil,0,xcode2);
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;

var
   a                            :tstr8;
   xresult                      :boolean;
   zok                          :boolean;
   v                            :string;
   e                            :string;
   v32                          :longint32;

   function mv(const x:string):boolean;
   begin

   result                       :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result                       :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult                         :=true;
a                               :=nil;
e                               :=gecTaskfailed;
v                               :='';
v32                             :=0;

try

//init
zok:=zzok(sender,7455);

if zok and (sender is tbasictoolbar) then
   begin

   //ours next
   xcode                        :=(sender as tbasictoolbar).ocode;
   xcode2                       :=strlow((sender as tbasictoolbar).ocode2);

   //nav toolbar handler 1st
   if (xcode2<>'nav.refresh') then
      begin

      if inav.xoff_toolbarevent(sender as tbasictoolbar) then goto skipend;

      end;

   end

else if zok and ((sender is tbasicnav) or (sender=ilist)) then
   begin

   if gui.mousedbclick and vidoubleclicks and (not iplaying) and (inav.valuestyle=nltFile) then imustplay:=true;

   goto skipend;

   end

else if zok and (sender=ijump) then
   begin

   imustpertpos                 :=ijump.hoverpert;

   goto skipend;

   end;

//get
if m('refresh') or m('nav.refresh') then//override "inav" refresh without our own
   begin

   inav.reload;

   ilastfilename                :='';

   end

else if m('home') then
   begin

   inav.folder                  :='';
   ilastfilename                :='';

   end

else if mv('intro:')        then iintro                       :=frcrange32(v32,0,4)
else if mv('ff:')           then iff                          :=frcrange32(v32,0,4)
else if m('list.showlinks') then ishowlistlinks               :=not ishowlistlinks
else if m('list.edit')      then ilist.showmenu2('playlist')
else if m('list.undo')      then xresult                      :=iplaylist.undo(e)
else if m('list.new')       then xresult                      :=iplaylist.new(e)
else if m('list.cut')       then xresult                      :=iplaylist.cut(e)//20mar2022
else if m('list.copy')      then xresult                      :=iplaylist.copy(e)
else if m('list.copyall')   then xresult                      :=iplaylist.copyall(e)
else if m('list.paste')     then xresult                      :=iplaylist.paste(e)
else if m('list.replace')   then xresult                      :=iplaylist.replace(e)
else if m('list.open')      then xresult                      :=iplaylist.open(e)
else if m('list.saveas')    then xresult                      :=iplaylist.save(e)
else if m('list.addfile')   then xresult                      :=iplaylist.addfile(inav.value,e)
else if m('show.list')      then showplaylist                 :=true
else if m('show.folder')    then showplaylist                 :=false
else if m('nav.toggle')     then ishownav                     :=not ishownav
else if m('bars.toggle')    then ishowbars                    :=not ishowbars
else if m('info.toggle')    then ishowinfo                    :=not ishowinfo
else if m('settings.toggle') then ishowsettings               :=not ishowsettings//15aug2025

else if m('vol.up')         then ivol.val                     :=ivol.val+5
else if m('vol.100')        then ivol.val                     :=100
else if m('vol.dn')         then ivol.val                     :=ivol.val-5

else if m('menu') then
   begin

   if showplaylist          then ilist.showmenu
   else                          inav.showmenu;

   end

else if m('jump.menu')      then ilist.showmenu2(xcode2)

else if m('prev') then
   begin

   if showplaylist then
      begin

      ilist.notidle;
      ilist.itemindex           :=frcmin32(pred(ilist.itemindex),0);

      end

   else begin

      inav.notidle;
      inav.itemindex            :=frcmin32(pred(inav.itemindex),0);

      end;

   end

else if m('next') then
   begin

   if showplaylist then
      begin

      ilist.notidle;
      ilist.itemindex           :=frcmax32(ilist.itemindex+1,frcmin32(pred(ilist.count),0));

      end

   else begin

      inav.notidle;
      inav.itemindex            :=inav.itemindex+1;

      end;

   end

else if m('rewind')         then mm_setpos(mm_pos-xffms)//10mar2021
else if m('fastforward')    then mm_setpos(mm_pos+xffms)//10mar2021
else if m('stop')           then imuststop                    :=true

else if m('play') then
   begin

   case iplaying of

   true:imuststop               :=true;
   else imustplay               :=true;

   end;//case

   end

else if m('largejumptitle') then ilargejumptitle              :=not ilargejumptitle
else if m('largejump')      then ilargejump                   :=not ilargejump

else if m('autoplay')       then iautoplay                    :=not iautoplay//16apr2021
else if m('saveas')         then xsaveas

else if m('folder') then
   begin

   if (inav.folder<>'')     then runLOW(inav.folder,'');

   end

else if mv('jumpstatus.')   then ijumpstatus                  :=frcrange32(v32,0,2)

else begin

   if system_debug then showtext('Unknown Command>'+xcode2+'<<');

   end;

skipend:

except;end;

//free
str__free(@a);

//update
xupdatebuttons;

//error
if not xresult then gui.poperror('',e);

end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
label
   skipend;

var
   bol1               :boolean;
   l                  :single;
   r                  :single;

begin
try

//timer100
if (slowms64>=itimer100) and iloaded then
   begin

   //play management
   case showplaylist of

   true:if mm_playmanagement('wav',imode.val,xintroms,imuststop,imustplay,iplaying,bol1,imustpertpos,imustpos,ilastpos,ilastfilename,nil,ilist,'',ijump) and bol1 then xfillinfo;
   else if mm_playmanagement('wav',imode.val,xintroms,imuststop,imustplay,iplaying,bol1,imustpertpos,imustpos,ilastpos,ilastfilename,inav,nil,'',ijump) and bol1 then xfillinfo;

   end;//case

   //reset
   timer__reset( itimer100 ,low__aorb(300,100,mm_playing)  );

   end;

//infotimer
if (slowms64>=iinfotimer) then
   begin

   //info
   if low__setstr(iinforef,bolstr(mm_deviceactive)+bolstr(mm_loop)+bolstr(mm_playing)+'|'+k64(iinfoid)+'|'+k64(mm_pos)+'|'+intstr32(iintro)+'|'+k64(mm_len)+'|'+k64(xintroms)+'|'+ilasterror+'|'+ilastfilename) then
      begin

      iinfo.paintnow;

      end;

   //reset
   timer__reset( iinfotimer ,low__aorb(700,350,mm_playing) );

   end;

//timer350
if (slowms64>=itimer350) then
   begin

   //page
   xupdatebuttons;

   //nav
   inav.xoff_toolbarsync(rootwin.xhead);

   //reset
   timer__reset( itimer350 ,350 );

   end;

//timer500
if (slowms64>=itimer500) then
   begin

   //links
   bol1                                   :=clip__canpastetext;
   ilistcap.benabled2['list.paste']       :=bol1;
   ilistcap.benabled2['list.replace']     :=bol1;

   //savesettings
   xautosavesettings;

   //update list mask
   nav__syncmask;

   iplaylist.partmask :=mask__user;

   //reset
   timer__reset( itimer500 ,500 );

   end;


//fasttimer
if (slowms64>=ifasttimer) then
   begin

   if ishowbars then
      begin

      if mm_playing then
         begin

         app__turbo;

         mm_meterValsFAST( l ,r );

         end

      else begin

         l:=0;
         r:=0;

         end;

      if (l>0) then l:=(l*ivol.val) / 100;
      if (r>0) then r:=(r*ivol.val) / 100;

      if (l<>ilastl) or (r<>ilastr) then
         begin

         ilastl       :=l;
         ilastr       :=r;

         ibarleft.paintnow;
         ibarright.paintnow;

         end;

      end;

   //reset
   timer__reset( ifasttimer ,low__aorb(500,33,mm_playing) );

   end;

//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;

if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.width;
   if (system_debugheight<=0) then system_debugheight:=gui.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;


skipend:

//can close audio system and app safely -> tell system it's safe to shutdown now - 10aug2025
if app__closeinited and mm_safetohalt then
   begin

   app__closepaused:=false;

   end;

except;end;
end;


function tapp.__oninfo(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   int1                         :longint32;
   p                            :longint32;
   xfileindex                   :longint32;
   xfilecount                   :longint32;
   xintro                       :longint32;
   xfilesize                    :longint64;
   xpos                         :longint32;
   xlen                         :longint32;
   xerrmsg                      :string;
   str1                         :string;
   bol1                         :boolean;
   xhavefile                    :boolean;

   function xfilter(const x,xdef:string):string;
   begin

   if xhavefile then result     :=x
   else              result     :=xdef;

   end;

   function s(const xcount:longint32):string;
   begin

   result                       :=insstr('s',xcount<>1);

   end;

   procedure t(const n:string);
   begin

   xcaption                     :=n;
   xtep                         :=tepnone;
   xtitle                       :=true;

   end;

   procedure c(const n,v:string);
   begin

   xcaption                     :=n + #9 + v;

   end;

begin

//defaults
result                          :=true;
xtep                            :=tepFNew20;
xtepcolor                       :=clnone;
xcaption                        :='';
xcaplabel                       :='';
xhelp                           :='';
xcode2                          :='';
xcode                           :=0;
xshortcut                       :=aknone;
xindent                         :=0;//xindex*5;
xflash                          :=false;//25mar2021
xenabled                        :=true;
xtitle                          :=false;//(xindex=3);
xsep                            :=false;
xhavefile                       :=iisfile;
xlen                            :=1;//safe default
xpos                            :=0;
xintro                          :=xintroms;
xfilesize                       :=mm_bytes;

//get
if xhavefile then
   begin

   xlen                         :=frcmin32(mm_len,1);
   xpos                         :=mm_pos;

   end;

case showplaylist of

true:begin

   xfileindex                   :=ilist.itemindex;
   xfilecount                   :=ilist.count;

   end;
else begin

   xfileindex                   :=ifileindex;
   xfilecount                   :=ifilecount;

   end;

end;//case

//.info
case xindex of

//technical
0   :t( 'Technical'                                                                                             );
1   :c( 'Device Status'         ,low__aorbstr('Offline','Online',mm_deviceactive)                               );
2   :c( 'Device Type'           ,strdefb(mm_deviceTypeLabel,'-')                                                );
3   :c( 'Name'                  ,xfilter(io__extractfilename(ilastfilename),'-')                                );
4   :c( 'Folder'                ,xfilter(io__extractfilepath(ilastfilename),'-')                                );
5   :c( 'Size'                  ,xfilter(low__b(xfilesize,true)+'  ( '+low__mb(xfilesize,true)+' )','-')        );
6   :c( 'File'                  ,xfilter(k64(1+xfileindex)+' / '+k64(xfilecount),'-')                           );

//playback
8   :t( 'Playback'                                                                                              );
9   :c( 'Elapsed'               ,low__uptime(xpos,(xlen>=3600000),(xlen>=60000),true,true,ijump.oms,#32)        );
10  :c( 'Remaining'             ,low__uptime(xlen-xpos,(xlen>=3600000),(xlen>=60000),true,true,ijump.oms,#32)   );
11  :c( 'Total'                 ,low__uptime(xlen,(xlen>=3600000),(xlen>=60000),true,true,ijump.oms,#32)        );
12  :c( 'Intro Mode'            ,low__aorbstr('Off','First '+k64(xintro div 1000)+' seconds',xintro>0)          );
13  :c( 'State'                 ,low__aorbstr('Stopped','Playing',mm_playing)                                   );

else begin

   xtep                         :=tepnone;

   end;

end;//case

end;

procedure tapp.onpaint__bar(sender:tobject);
var
   a                  :tbasiccontrol;
   s                  :tclientinfo;
   l                  :single;
   r                  :single;
   v,vb:double;

   procedure xbar(const xpert:double;const xstyle:string;xerase:boolean);
   var
      vpos:longint;
   begin

   vpos :=frcrange32( trunc( (1-xpert) * (s.cs.bottom-s.cs.top+1) ) + s.cs.top, s.cs.top, s.cs.bottom);

   if xerase             then a.ffillArea( area__make(s.cs.left,s.cs.top,s.cs.right,vpos),s.back,false);

   if (vpos<s.cs.bottom) then
      begin

      a.fshadeArea2( area__make(s.cs.left,vpos,s.cs.right,s.cs.bottom), s.colhover2.x,s.colhover2.y,s.colhover2.y,s.colhover2.x,5,255,false);

      end;

   end;

   procedure xbar2(const xpert:double;xback,xpeak:longint;const xswapcols:boolean);
   var
      vgap,vpos:longint;
   begin

   if xswapcols then low__swapint(xback,xpeak);

   vpos  :=frcrange32( trunc( (1-xpert) * (s.cs.bottom-s.cs.top+1) ) + s.cs.top, s.cs.top, s.cs.bottom);
   vgap  :=trunc(0.2*(s.cs.right-s.cs.left+1));

   if (vpos<s.cs.bottom) then
      begin

      a.fshadeArea2( area__make(s.cs.left+vgap,vpos,s.cs.right-vgap,s.cs.bottom), xback,xpeak,xpeak,xback,10,255,true);

      end;

   end;
begin

//check
if (sender is tbasiccontrol) then a:=(sender as tbasiccontrol)
else                              exit;

//init
a.infovars2(s,true);


if      (a = ibarleft)  then v  :=ilastl
else if (a = ibarright) then v  :=ilastr
else                         v  :=0;

vb                              :=0;



//overal volume indicator
xbar(v,'g-10',true);

//bass volume indicator
xbar2(vb*0.9, int__splice24(0.25+vb,s.back,s.colhover2.y), int__splice24(vb,s.info.hover,s.font), false);

end;


end.
