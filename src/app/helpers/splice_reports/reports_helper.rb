#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      #logger.info("HELPER Record:" + record.to_s)
      uuid = record['instance_identifier'].to_s
      System.where(:uuid=>uuid).first
    end
 
    def get_system_compliance(system)
      compliance = ""
      if system.compliance_color == "green"
        compliance = "Current"
      elsif system.compliance_color == "yellow"
        compliance = "Insufficient" 
      else
        compliance = "Invalid" 
      end
    end

    def get_status_color(record)
      status = record['entitlement_status']['status']
      if status == "current"
        color = "green"
      elsif status == "invalid"
        color = "red"
      else
        color = "yellow"
      end
      return color
    end

    def get_status_message(record)
      status = record['entitlement_status']['status']
      date = record['checkin_date']
      if status == "current"
        message = "Current on " + format_time(date)
      elsif status == "invalid"
        message = "Invalid on " + format_time(date)
      else
        message = "Insuffcient on " + format_time(date)
      end
      return message
    end
    
    def get_spacewalk_link(record)
      if record['facts'].to_s.include? 'spacewalk-server-hostname'
        space_url = ""
        spacewalk_server = ""
        system_id = ""
        #i = 0
        record['facts'].each do |f| 
          #logger.info(i) 
          #logger.info(f[0])
          if f[0].include? "spacewalk-server-hostname"
            spacewalk_server = f[1]
          end
          if f[0].include? "system.id"
            system_id = f[1]
          end
          #i += 1
        end
        space_url = "https://#{spacewalk_server}/rhn/systems/details/Overview.do?sid=#{system_id}"
        logger.info("space_url: #{space_url}")
        return space_url
      else
        return nil
      end  

    end

    def get_reasons(record)
      reasons = record['entitlement_status']['reasons']
      logger.info("REASONS: " + reasons.to_s)
      return reasons.as_json
    end
        
    def system_link(system)
      systems_path(system.id, :anchor => "/&list_search=id:#{system.id}&panel=system_#{system.id}")
    end

    def get_filter_details(filter)
      txt =  "<li>Filter Name: #{filter["name"]}</li> 
             <li>Status: #{filter["status"]}</li> "
    end
   
    def get_checkin(system)
      if system.checkin_time
        return  format_time(system.checkin_time)
      end
      _("Never checked in")
    end


  end
end
