#################################### Create Sections. ##########################################################
section_hash = {
  2.5 => 'Beginner',
  3.0 => 'Advance Beginner',
  3.5 => 'Intermediate',
  4.0 => 'Advanced'
}

section_hash.each do |key, value|
  Section.create!(name: value, rating: key, overview_text: "I am #{value}")
end

#################################### Script to add training modules locally. #################################### 
####################### Remember to place the main Video folder in root app. ####################################

# Define the path to the main folder
main_folder_path = Rails.root.join('playerU-courses')

# Iterate through the folders in the main folder
Dir.foreach(main_folder_path) do |folder_name|
  next if folder_name.start_with?('.') # Skip hidden files or directories like .DS_Store, ., ..

  folder_path = File.join(main_folder_path, folder_name)
  course = Course.create!(title: folder_name)

  Dir.foreach(folder_path) do |video_file|
    next if video_file.start_with?('.') # Skip hidden files

    video_path = File.join(folder_path, video_file)
    section = Section.find_by(rating: video_file.chomp('.mp4').match(/[-+]?\d*\.?\d+$/)[0].to_f)
    if section.nil?
      puts "No section for rating #{video_file.chomp('.mp4').match(/[-+]?\d*\.?\d+$/)[0].to_f}"
      break
    end

    # Create a new training module record
    training_module = TrainingModule.create!(
      name: File.basename(video_file, File.extname(video_file)),
      course_id: course.id,
      section_id: section.id
    )

    training_module.training_video.attach(
      io: File.open(video_path),
      filename: video_file,
      content_type: `file --mime-type -b #{Shellwords.escape(video_path)}`.strip
    )

    puts "Created TrainingModule for #{video_file} under #{course.title} course and section #{section.name}"
  end
end

#################################################################################################################

########################### Script to add training modules via AWS S3 Bucket. #################################### 
require 'aws-sdk-s3'

# AWS S3 Configuration
bucket_name = 'playeru-staging'
main_folder_path = 'playerU-courses/'

# Initialize the S3 client
s3 = Aws::S3::Client.new(
  region: Rails.application.credentials.dig(:aws, :region),
  access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
)

# List objects in the main folder
s3.list_objects_v2(bucket: bucket_name, prefix: main_folder_path, delimiter: '/').common_prefixes.each do |folder|
  folder_name = folder.prefix.split('/').last
  puts "Processing folder: #{folder_name}"

  course = Course.create!(title: folder_name)

  # List objects in the folder
  s3.list_objects_v2(bucket: bucket_name, prefix: "#{folder.prefix}").contents.each do |object|
    next if object.key.end_with?('/') # Skip folders

    video_file = object.key.split('/').last
    video_path = object.key

    # Extract rating from the file name
    rating_match = video_file.chomp('.mp4').match(/[-+]?\d*\.?\d+$/)
    if rating_match.nil?
      puts "No rating found in #{video_file}"
      next
    end

    rating = rating_match[0].to_f
    section = Section.find_by(rating: rating)
    if section.nil?
      puts "No section for rating #{rating}"
      next
    end

    # Create a new training module record
    training_module = TrainingModule.create!(
      name: File.basename(video_file, File.extname(video_file)),
      course_id: course.id,
      section_id: section.id
    )

    # Download the file from S3 temporarily to attach it
    video_tempfile = Tempfile.new(video_file)
    s3.get_object(bucket: bucket_name, key: video_path, response_target: video_tempfile.path)

    training_module.training_video.attach(
      io: File.open(video_tempfile.path),
      filename: video_file,
      content_type: `file --mime-type -b #{Shellwords.escape(video_tempfile.path)}`.strip
    )

    video_tempfile.close
    video_tempfile.unlink # Clean up the tempfile

    puts "Created TrainingModule for #{video_file} under #{course.title} course and section #{section.name}"
  end
end


#################################################################################################################
##################### Script to add User training modules for existing users. ###################################

User.find_each do |user|
  Section.find_each do |section|
    if section.rating == 2.5
      section.training_modules.each_with_index do |training_module, index|
        status = index.zero? ? 'current' : 'pending' # First module is current, others are pending
        UsersTrainingModule.create(user: user, training_module: training_module, status: status)
      end
    else
      section.training_modules.each do |training_module|
        UsersTrainingModule.create(user: user, training_module: training_module, status: 'pending')
      end
    end
  end
end

#################################################################################################################
##################### Add sequence for watching modules #########################################################

data = {
  "lob 3" => {section: 3, sequence: 7},
  "lobs 2.5" => {section: 2.5, sequence: 7},
  "recovery 2.5" => {section: 2.5, sequence: 11},
  "recovery 3.5" => {section: 3.5, sequence: 11},
  "recovery 3.0" => {section: 3, sequence: 11},
  "swing 2.5" => {section: 2.5, sequence: 2},
  "swing 3.5" => {section: 3.5, sequence: 2},
  "swing 3.0" => {section: 3, sequence: 2},
  "swing 4" => {section: 4, sequence: 2},
  "return 3.5" => {section: 3.5, sequence: 6},
  "return 2.5" => {section: 2.5, sequence: 6},
  "return 3" => {section: 3, sequence: 6},
  "dink 3.0" => {section: 3, sequence: 9},
  "spin 3.0" => {section: 3, sequence: 10},
  "serve 3.5" => {section: 3.5, sequence: 5},
  "dink 3.5" => {section: 3.5, sequence: 9},
  "serve 2.5" => {section: 2.5, sequence: 5},
  "serve 3" => {section: 3, sequence: 5},
  "dinking 2.5" => {section: 2.5, sequence: 9},
  "dink 4" => {section: 4, sequence: 9},
  "serve 4" => {section: 4, sequence: 5},
  "weight distribution 2.5" => {section: 2.5, sequence: 4},
  "weight distribution 3" => {section: 3, sequence: 4},
  "weight distribution 3.5" => {section: 3.5, sequence: 4},
  "grip 2.5" => {section: 2.5, sequence: 1},
  "stance-footwork 3.5" => {section: 3.5, sequence: 3},
  "stance-footwork 3.0" => {section: 3, sequence: 3},
  "stance-footwork 2.5" => {section: 2.5, sequence: 3},
  "stance-footwork 4" => {section: 4, sequence: 3},
  "overhead 2.5" => {section: 2.5, sequence: 8},
  "overhead 3.5" => {section: 3.5, sequence: 8},
  "overhead 3.0" => {section: 3, sequence: 8}
}

sections = Section.all
training_modules = TrainingModule.where(name: data.keys)

data.each do |key, value|
  section = sections.find { |s| s.rating == value[:section] }
  module_instance = training_modules.find { |tm| tm.name == key && tm.section_id == section.id }
  next if module_instance.nil?

  module_instance.update(sequence: value[:sequence])
end

#################################################################################################################
##################### Update S3 video URLs to AWS cloudFront URLs on staging ####################################

include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options[:host] = 'http://54.80.136.93'

Course.all.each do |course|
  course.training_modules.each do |module_instance|
    original_url = url_for(module_instance.training_video)
    file_name = File.basename(URI.parse(original_url).path)
    cloudfront_domain = Rails.application.credentials.dig(:aws, :cloudfront_domain)
    cloudfront_url = "#{cloudfront_domain}/playerU-courses/#{course.title}/#{file_name}"

    module_instance.update!(cloudfront_url: cloudfront_url)
  end
end

#################################################################################################################
##################### Update duration via cloudfront/s3 url of video modules ####################################

require 'open-uri'
require 'tempfile'
require 'streamio-ffmpeg'

def fetch_video_duration(video_url)
  Tempfile.create(['video', '.mp4']) do |tempfile|
    # Download the video to a temporary file
    URI.open(video_url) do |remote_video|
      tempfile.binmode
      tempfile.write(remote_video.read)
      tempfile.rewind
    end

    # Use FFMPEG to analyze the video
    movie = FFMPEG::Movie.new(tempfile.path)
    duration_in_seconds = movie.duration # Returns duration in seconds

    # Format the duration into MM:SS
    minutes = (duration_in_seconds / 60).to_i
    seconds = (duration_in_seconds % 60).to_i
    return format('%02d:%02d', minutes, seconds)
  end
rescue StandardError => e
  Rails.logger.error("Error calculating video duration: #{e.message}")
end

TrainingModule.all.each do |module_instance|
  duration = fetch_video_duration(module_instance.cloudfront_url)
  module_instance.update_column(:duration, duration)
end
Course.find_by_title('Weight Distribution').training_modules.each do |module_instance|
  duration = if module_instance.section_id == 1
    '00:13'
  elsif module_instance.section_id == 2
    '00:16'
  else
    '00:12'
  end
  module_instance.update_column(:duration, duration)
end

#################################################################################################################
####################################### Add overview text in sections ###########################################
text_hash = {
  2.5 => "<p>Welcome to <b>Course 1: Beginners</b> – the perfect starting point for your pickleball journey! This course is designed to help you build a solid foundation by mastering the basics. You'll learn the proper grip to control your paddle, the ideal stance for stability and agility, and how to distribute your weight effectively for powerful and precise movements. By the end of this course, you'll be ready to hit the court with confidence. Let's get started!</p>",
  3.0 => "<p>Take your pickleball skills to the next level with <b>Course 2: Advanced Beginner!</b> This course builds on the fundamentals and focuses on refining your swing, perfecting your serve, and mastering effective returns. You'll gain the skills and confidence needed to elevate your game and take on new challenges on the court. Let’s keep the momentum going!</p>",
  3.5 => "<p>Elevate your pickleball game with <b>Course 3: Intermediate!</b> This course dives into advanced techniques, including precision dinking, strategic lobs, and powerful overhead shots. You'll learn how to control the pace, outmaneuver opponents, and execute shots with accuracy and confidence. Perfect for players ready to dominate the court with finesse and power. Let’s take your skills to new heights!</p>",
  4.0 => "<p>Master the art of advanced pickleball play with <b>Course 4: Advanced!</b> This course focuses on developing spin techniques to add unpredictability to your shots and sharpening your recovery skills to maintain control during fast-paced rallies. These advanced strategies will give you a competitive edge and elevate your gameplay to a professional level. Ready to conquer the court? Let’s get started!</p>"
}

text_hash.each do |key, value|
  Section.find_by(rating: key).update(overview_text: value)
end
#################################################################################################################
####################################### Add sequence in Courses #################################################

order_hash = {"Dink" => 7, "Weight Distribution" => 3, "Stance" => 2, "Lob" => 8, "Recovery" => 11, "Swing" => 4, "Return" => 6, "spin" => 10, "Serve" => 5, "grip" => 1, "Overhead" => 9}
order_hash.each do |key, value|
  Course.find_by(title: key).update(sequence: value)
end

#################################################################################################################
####################### Change section association with training modules ########################################

section_with_course = {
  'grip' => 2.5,
  'Stance' => 2.5,
  'Weight Distribution' => 2.5,
  'Swing' => 3.0,
  'Serve' => 3.0,
  'Return' => 3.0,
  'Dink' => 3.5,
  'Lob' => 3.5,
  'Overhead' => 3.5,
  'spin' => 4.0,
  'Recovery' => 4.0
}

Course.all.each do |course|
  section = Section.find_by(rating: section_with_course[course.title])
  course.training_modules.update_all(section_id: section.id)
end

training_modules_data = {
  'Beginner' => [
    { name: "grip 2.5", sequence: 1 },
    { name: "stance-footwork 2.5", sequence: 2 },
    { name: "stance-footwork 3.0", sequence: 3 },
    { name: "stance-footwork 3.5", sequence: 4 },
    { name: "stance-footwork 4", sequence: 5 },
    { name: "weight distribution 2.5", sequence: 6 },
    { name: "weight distribution 3", sequence: 7 },
    { name: "weight distribution 3.5", sequence: 8 }
  ],
  'Advanced Beginner' => [
    { name: "serve 2.5", sequence: 1 },
    { name: "serve 3", sequence: 2 },
    { name: "serve 3.5", sequence: 3 },
    { name: "serve 4", sequence: 4 },
    { name: "swing 2.5", sequence: 5 },
    { name: "swing 3.0", sequence: 6 },
    { name: "swing 3.5", sequence: 7 },
    { name: "swing 4", sequence: 8 },
    { name: "return 2.5", sequence: 9 },
    { name: "return 3", sequence: 10 },
    { name: "return 3.5", sequence: 11 }
  ],
  'Intermediate' => [
    { name: "dinking 2.5", sequence: 1 },
    { name: "dink 3.0", sequence: 2 },
    { name: "dink 3.5", sequence: 3 },
    { name: "dink 4", sequence: 4 },
    { name: "lobs 2.5", sequence: 5 },
    { name: "lob 3", sequence: 6 },
    { name: "overhead 2.5", sequence: 7 },
    { name: "overhead 3.0", sequence: 8 },
    { name: "overhead 3.5", sequence: 9 }
  ],
  'Advanced' => [
    { name: "spin 3.0", sequence: 1 },
    { name: "recovery 2.5", sequence: 2 },
    { name: "recovery 3.0", sequence: 3 },
    { name: "recovery 3.5", sequence: 4 }
  ]
}

# Iterate through each section and update sequences
training_modules_data.each do |section_name, modules|
  section = Section.find_by(name: section_name)
  next unless section

  modules.each do |module_data|
    training_module = section.training_modules.find_by(name: module_data[:name])
    if training_module
      training_module.update(sequence: module_data[:sequence])
      puts "Updated #{module_data[:name]} to sequence #{module_data[:sequence]}"
    else
      puts "Training module #{module_data[:name]} not found in section #{section_position}"
    end
  end
end

# CHanging names of training_modules

NUMERIC_REPLACEMENT = {
  "2.5" => "1",
  "3.0" => "2",
  "3"   => "2",
  "3.5" => "3",
  "4.0" => "4",
  "4"   => "4"
}

# Iterate over all training modules
TrainingModule.find_each do |module_record|
  original_name = module_record.name
  name_parts = original_name.split(' ')
  base_name = name_parts[0...-1].join(' ') # Everything except the numeric value
  numeric_value = name_parts.last          # Last part is the numeric value

  # Adjust base name special cases
  base_name = base_name.downcase == "dink" ? "Dinking" : base_name.titleize
  base_name = base_name.gsub("Weight Distribution", "Weight Dist.")

  new_numeric_value = NUMERIC_REPLACEMENT[numeric_value]
  new_name = "The #{base_name} #{new_numeric_value}"
  module_record.update!(name: new_name)
end

puts "Training module names updated successfully!"
#################################################################################################################
