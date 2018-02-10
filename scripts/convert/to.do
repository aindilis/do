(we first need to eliminate redundancies and build errors)

(we need to setup Inotify2 to detect new files, compile and load
 them if unique, and detect changes and reload them.  this has to
 be integrated into formalog either through FLP or a different
 instance.)

(then we need to properly load as an optional or dynamic module
 from FLP)

(look into FLP module system)

(also need to catch compilation errors when recompiling, i.e.:
 trying: <<<<REDACTED>>>>
 file-exists
 Modification of non-creatable array value attempted, subscript -4 at /usr/share/perl5/Manager/Misc/Light.pm line 136.
 at /usr/share/perl5/PerlLib/SwissArmyKnife.pm line 25.
 PerlLib::SwissArmyKnife::__ANON__("Modification of non-creatable array value attempted, subscrip"...) called at /usr/share/perl5/Manager/Misc/Light.pm line 136
 Manager::Misc::Light::Parse(Manager::Misc::Light=HASH(0x242d6e0), "Contents", "(API not done\x{a} (quick Hit proof of concept)\x{a} ()\x{a} )\x{a}\x{a}()\x{a}\x{a}\x{a}From"...) called at /usr/share/perl5/Do/Convert/DoToProlog.pm line 152
 Do::Convert::DoToProlog::IsDoFile(Do::Convert::DoToProlog=HASH(0x2406e78), "File", "/Doug/data/ai.frdcsa.org/s3/git-repos/home-andrewdo/eric-2015"...) called at /usr/share/perl5/Do/Convert/DoToProlog.pm line 42
 Do::Convert::DoToProlog::IndexDocuments(Do::Convert::DoToProlog=HASH(0x2406e78)) called at /var/lib/myfrdcsa/codebases/minor/do-convert/convert-do-to-prolog line 6
 )

(generate /var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/generate-qlf-helper.pl)

(do_convert:getShoppingList(X),do_convert:write_list(X).)

