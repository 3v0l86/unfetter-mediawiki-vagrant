# == Class: role::unfetter
# Configures extensions for Unfetter in MediaWiki.
class role::unfetter {
    mediawiki::wiki {'attack': }
    include ::role::semanticmediawiki
    include ::role::variables

    require_package('php-luasandbox')

    mediawiki::extension { 'Scribunto':
        settings => [
            '$wgScribuntoEngineConf["luasandbox"]["profilerPeriod"] = false',
            '$wgScribuntoDefaultEngine = "luasandbox"',
        ],
        notify   => Service['apache2'],
        require  => [
            Package['php-luasandbox', 'hhvm-luasandbox'],
        ],
    }

    mediawiki::extension { 'ParserFunctions': 
        settings => '$wgPFEnableStringFunctions = true;',
    }

    mediawiki::composer::require { 'SemanticForms': 
        package => 'mediawiki/semantic-forms',
        version => '3.7',
    }

    mediawiki::settings { 'SemanticForms':
        values   => {
            sfgMaxLocalAutocompleteValues => 200,
            sfgAutocompleteOnAllChars => true,
        },
    }

    mediawiki::composer::require { 'SemanticCite': 
        package => 'mediawiki/semantic-cite',
        version => '1.0.0',
    }

    mediawiki::extension { 'SemanticDrilldown': 
        settings => '$sdgHideCategoriesByDefault = true;',
    }

    mediawiki::extension { 'SemanticInternalObjects': }

    # CAR Settings
    mediawiki::extension { 'SemanticCompoundQueries': }

    include ::role::interwiki

    mediawiki::extension { 'Arrays': }

    mediawiki::extension { 'ExternalData': }

    mediawiki::extension { 'Loops': }

    mediawiki::settings { 'DisplayTitle':
        values => { 
            wgAllowDisplayTitle => true,
            wgRestrictDisplayTitle => false
        }  
    }

    mediawiki::settings { 'SMWQueryMax' :
        values => {
            smwgQMaxSize => 100,
            smwgQMaxDepth => 100,
        }
    }

    mysql::sql { 'Set ATT&CK Interwiki prefix' :
        sql => "USE wiki; INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('attack', 'http://attack.wiki.local.wmftest.net:8080/wiki/\\\$1', 0, 0);",
        unless => "USE wiki; SELECT 1 FROM interwiki WHERE iw_prefix = 'attack';",
        require => Mediawiki::Extension['Interwiki'],
    }

    file { '/etc/unfetter':
        ensure => 'directory',
    }
    file { '/etc/unfetter/output.xml':
        source => 'puppet:///modules/unfetter/output.xml',
        audit => content,
    }

    include ::mysql
    exec { 'remove wiki contents': 
        command => "/usr/bin/mysql -B --disable-column-names -uroot -p${::mysql::root_password} -e \"use wiki; select page_namespace, page_title from page\" | python /vagrant/puppet/modules/unfetter/files/all_pagenames.py http://localhost/w/api.php | /usr/local/bin/mwscript deleteBatch.php",
        refreshonly => true,
        require => [ Exec['composer update /vagrant/mediawiki'], Exec['update_all_databases'] ],
        subscribe => File['/etc/unfetter/output.xml'],
        timeout => 2000,
    }

    mediawiki::maintenance { "import CAR":
        command => "/usr/local/bin/mwscript importDump.php --wiki=wiki '/vagrant/puppet/modules/unfetter/files/output.xml'",
        refreshonly => true,
        subscribe => Exec['remove wiki contents'],
        timeout => 3000,
    }

    mediawiki::settings {'Copyright':
        values => { 
            wgRightsPage => "MediaWiki:Copyright",
        }
    }

    file { '/etc/unfetter/attack-output.xml':
        source => 'puppet:///modules/unfetter/attack-output.xml',
        audit => content,
    }

    include ::mediawiki::multiwiki
    exec { 'remove wiki contents_attack': 
        command => "/usr/bin/mysql -B --disable-column-names -uroot -p${::mysql::root_password} -e \"use attackwiki; select page_namespace, page_title from page\" | python /vagrant/puppet/modules/unfetter/files/all_pagenames.py http://attack${::mediawiki::multiwiki::base_domain}${::port_fragment}/w/api.php | /usr/local/bin/mwscript deleteBatch.php --wiki=attackwiki",
        refreshonly => true,
        require => [ Exec['composer update /vagrant/mediawiki'], Exec['update_all_databases'] ],
        subscribe => File['/etc/unfetter/attack-output.xml'],
        timeout => 3000,
    }

    mediawiki::maintenance { "import ATTACK":
        command => "/usr/local/bin/mwscript importDump.php --wiki=attackwiki '/vagrant/puppet/modules/unfetter/files/attack-output.xml'",
        refreshonly => true,
        subscribe => Exec['remove wiki contents_attack'],
        timeout => 6000,
    }

    exec { "rebuildallcar1":
        command => "/usr/local/bin/mwscript rebuildall.php",
        refreshonly => true,
        subscribe => Mediawiki::Maintenance["import CAR"],
        timeout => 6000,
    }

    exec { "rebuildallattack1":
        command => "/usr/local/bin/mwscript rebuildall.php attackwiki",
        refreshonly => true,
        subscribe => Mediawiki::Maintenance["import ATTACK"],
        timeout => 6000,
    }

    file { 'caretdir':
        path => '/var/www/caret',
        source => 'puppet:///modules/unfetter/caret',
        recurse => true,
    }
}
