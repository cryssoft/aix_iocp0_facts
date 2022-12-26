#
#  FACT(S):     aix_iocp0
#
#  PURPOSE:     This custom fact returns a hash of "lsattr -l iocp0 -H -E" 
#		output with name->value.
#
#  RETURNS:     (hash)
#
#  AUTHOR:      Chris Petersen, Crystallized Software
#
#  DATE:        March 16, 2021
#
#  NOTES:       Myriad names and acronyms are trademarked or copyrighted by IBM
#               including but not limited to IBM, PowerHA, AIX, RSCT (Reliable,
#               Scalable Cluster Technology), and CAA (Cluster-Aware AIX).  All
#               rights to such names and acronyms belong with their owner.
#
#		NEVER FORGET!  "\n" and '\n' are not the same in Ruby!
#
#-------------------------------------------------------------------------------
#
#  LAST MOD:    April 15, 2021
#
#  MODIFICATION HISTORY:
#
#  202104/15 - cp - Added the second part of the fact hash based on current state.
#
#-------------------------------------------------------------------------------
#
Facter.add(:aix_iocp0) do
    #  This only applies to the AIX operating system
    confine :osfamily => 'AIX'

    #  Define an empty hash to return
    l_aixIocp0 = {}

    #  Do the work
    setcode do
        #  Run the command to look at the I/O "completion" settings
        l_lines = Facter::Util::Resolution.exec('/usr/sbin/lsattr -l iocp0 -H -E 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Skip the header and blank lines
            next if ((l_oneLine =~ /^attribute /) or (l_oneLine =~ /^$/))

            #  Strip leading and trailing whitespace and split on any whitespace
            l_list = l_oneLine.strip().split()

            #  Stash the data in the hash as name -> value
            l_aixIocp0[l_list[0]] = l_list[1]
        end

        #
        #  2021/04/15 - cp - Look at the current settings too
        #
        l_lines = Facter::Util::Resolution.exec('/usr/sbin/lsdev -l iocp0 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Strip leading and trailing whitespace and split on any whitespace
            l_list = l_oneLine.strip().split()

            #  Stash the data in the hash as name -> value
            if (l_list[0] == 'iocp0')
                l_aixIocp0['current_state'] = l_list[1]
            end
        end

        #  Implicitly return the contents of the variable
        l_aixIocp0
    end
end
