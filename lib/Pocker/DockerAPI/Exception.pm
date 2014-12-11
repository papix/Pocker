package Pocker::DockerAPI::Exception;
use strict;
use warnings;
use utf8;

use parent 'Exception::Tiny';
use Class::Accessor::Lite ( ro => [qw/ res /] );

package Pocker::DockerAPI::Exception::BadStatusCode {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
    use Class::Accessor::Lite ( ro => [qw/ status_code /] );
}

package Pocker::DockerAPI::Exception::BadParameter {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}
package Pocker::DockerAPI::Exception::ServerError {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}
package Pocker::DockerAPI::Exception::NoSuchImage {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}

package Pocker::DockerAPI::Exception::NoSuchContainer {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}
package Pocker::DockerAPI::Exception::ImpossibleToAttach {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}
package Pocker::DockerAPI::Exception::ContainerAlreadyStarted {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}
package Pocker::DockerAPI::Exception::ContainerAlreadyStopped {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}

package Pocker::DockerAPI::Exception::Conflict {
    use parent -norequire, 'Pocker::DockerAPI::Exception';
}

1;
