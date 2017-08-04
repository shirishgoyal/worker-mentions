# name: worker-mentions
# about: Plugin to allow using @workers tag to mention all workers for a project
# version: 0.0.1
# authors: Daemo

enabled_site_setting :worker_mentions_enabled
enabled_site_setting :worker_mentions_group_name
enabled_site_setting :worker_mentions_api

register_asset "javascripts/details.js"
register_asset "stylesheets/details.scss"

require 'app/services/post_alerter.rb'

after_initialize do

	class PostAlerter
		def expand_group_mentions(groups, post)
		    return unless post.user && groups

		    Group.mentionable(post.user).where(id: groups.map(&:id)).each do |group|
		      topic_id = post.topic_id

		      # check if group is one mentioned in settings
		      if SiteSetting.worker_mentions_api && topic_id && group.name==Settings.worker_mentions_group_name
		      	workers = fetch_workers(topic_id)
		      	group.user_count = workers.length
		      	group.users = workers
		      end

		      next if group.user_count >= SiteSetting.max_users_notified_per_group_mention
		      yield group, group.users
		    end

		end

		def fetch_workers(topic_id)
		    response = Excon.get(SiteSetting.worker_mentions_api+topic_id)
		    response.body.to_json
		end
	  
	end

end

