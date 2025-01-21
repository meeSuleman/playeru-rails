# app/services/module_description_service.rb
class ModuleDescriptionService
  attr_reader :module_name

  DESCRIPTION_HASH = {
    "The Lob 2" => "There are defensive and offensive lobs. Either one will be much more effective if you are on balance when hitting them. If your opponent is crashing the kitchen line hard, try an offensive lob to catch them off gaurd.",
    "The Lobs 1" => "Right now you are probably using a lob at the wrong time, and not effectively. A thing you can focus on is high enough lobs to get your balance and position back on the court in a scramble. It isn't easy to put away a lob as long as you get back to a nuetral position as a defender.",
    "The Recovery 1" => "As you hit the ball always expect it is coming back to you. You don't want to hit and watch, hit and recover! The next ball is coming back quick.",
    "The Recovery 3" => "Balance and recovery is key to getting to a 4.0. In order to be ready to take the next ball you need to in the best position possible - that means stay on your toes and get to the right position on the court and that usually means the kitchen line!",
    "The Recovery 2" => "Hit and recover is something you can say to yourself each shot. But remember, you need to recover sometimes even when you aren't hitting. Don't just watch your partner play, move with them, and get ready for the next ball - this one may come to you!",
    "The Swing 1" => "Lets talk about your swing. A pickleball swing should be compact and linear on most shots. Wether you are dinking or driving, you don't need a backswing, keep it in front and steady. A simple swing is all thats needed to direct the ball where you want it.",
    "The Swing 3" => "You swing is looking very simple and smooth. Balance, recovery, and ready position all help you achieve a perfect swing. You need to be starting from the same position every time, so get the paddle back to ready position.",
    "The Swing 2" => "You are keeping your swing compact, but even when you take a big cut and try and drive keep it simple. Big swings lead to errors and inconsitency",
    "The Swing 4" => "You will start to mix in some variation in your swing allowing for spin, drops, and misdirection. All of this can be achieved only when you have good balance and stance as well as keeping the swing smooth.",
    "The Return 3" => "I see you are consistnently making returns, but in order to get to a 4.0 you also need to make your opponent's 3rd shot difficult. Make sure you are getting that return deep, and focus on the weaker opponent. A 4.0 needs to be able to strategize where and why!",
    "The Return 1" => "If the Serve is the most important shot, the return is the second most important. The key to get to a 3.0 is making returns. So stay low, make contact in front and make your opponent hit their 3rd shot!",
    "The Return 2" => "In order to get to a 3.5 you need to make every return and get to the kitchen line right away. In order to do this you need to be balanced, you need to watch the ball hit your paddle, and you need to follow through with your weight moving foward. Remember, make your opponent hit their 3rd shot!",
    "The Dinking 2" => "The consistency is getting there, but you need to be able to hit a dink cross court and down the line. Control your body, keep balanced, and keep your paddle in front of you. Don't think, just Dink!",
    "The Spin 2" => "Adding a little spin to your game can help get you to the 3.5 level. Try both covering the ball as you swing to add in a little top spin. This means you need to hit the ball will the face slightly down on the paddle, and an upward motion in your swing.",
    "The Serve 3" => "Your serve is looking strong! But in order to get to a 4.0 level you need more depth and more power while still being consistent. You cannot afford to miss balls short, but if you want to get to the kitchen on the 3rd ball you need a deep serve.",
    "The Dinking 3" => "Clearly you are capable of dinking consistently, but to get to a 4.0 lets try adding some agressive dinks into your game. Try pushing your opponent back from the kitchen line. Of course, consistency is required, but mixing up your shot selection and placement will pay dividends when at the kitchen line.",
    "The Serve 1" => "The serve is the most important shot of the point, because its the first shot. The key in getting to a 3.0 is making a LOT of serves. The first step is making serves, hit the serve in and get the point started. If you can make 9 out of 10 serves in, you'll be a 3.0 in no time.",
    "The Serve 2" => "Getting to a 3.5 is going to take consistency and depth. You absolutely cannot miss serves short, and you need to start pushing your opponent deep with deeper serves.",
    "The Dinking 1" => "Dinking is what makes pickleball ... pickleball! You need to be able to slow the ball down if you want to get to a 3.0. Try hitting 20 dinks in a row, then 50, then 100. The key with dinking is balance, watching the ball, and practice!",
    "The Dinking 4" => "Great control on your dinking. Your balance is great, your hands are soft, and your contorl is excellent. Make sure you are staying ready and on your toes. If you want to get to a 4.5 you need to be ready to pounce on any opportunity your opponent gives you to speed up with your aggresive and consistent dinks.",
    "The Serve 4" => "Great serving! Lets try to add some spin, and shot placement in order to get up to a 4.5. Mix up your depth, placement, and spin in order to keep your opponent off gaurd. But don't forget - consistency is still key!",
    "The Weight Dist. 1" => "You are probably still finding your footing and balance on the court. Keep it simple right now, focus on being light on your feet and keep your feet in a wide athletic stance.",
    "The Weight Dist. 2" => "As you get more comfortable moving around the court, always keep your weight distribution balanced. You shouldn't be leaning back, or leaning to far foward. The key to good balance is being able to move any direction at any moment!",
    "The Weight Dist. 3" => "Great balance. Small, quick steps will help you get to a 4.0. Move quickly, but don't rush. If you keep your center of gravity between your shoulders even on tough shots outside your normal hitting zone, you'll be ready for anything!",
    "The Grip 1" => "We are playing pickleball, but hold the paddle like a hammer! This is called a continental grip, and its the only grip you need to worry about right now. Keep a firm grip, but don't squeeze to hard. Think about squeezing only on contact and being relaxed between hits.",
    "The Stance Footwork 3" => "You are moving great, but make sure you are ready for anything. You need to keep your eyes on your opponent. If they have a high ball take a step back, if they are dinking get low. Constantly adjusting and moving is key to great footwork.",
    "The Stance Footwork 2" => "You are in athletic position most of the time, but to get to a 3.5 you need to be moving. You need to be constantly adjusting your position and feet following your partner and adjusting to your opponent. Do not stop moving!",
    "The Stance Footwork 1" => "You can improve your stance and footwork by remembering 3 easy things:
      1) get into athletic position, feet shoulder width apart, knees slightly bent, and hands up!
      2) keep on your toes
      3) keep moving.
If you can do those 3 things you'll be a 3.0 in no time. It all starts with your feet!",
    "The Stance Footwork 4" => "Great work staying active and moving. Keep low and on your toes and always look for an opporunity to take control of the point.",
    "The Overhead 1" => "So you probably are not making contact with every overhead and put away. Wiffs happen! Make sure you are moving your feet and getting your paddle up quickly. In order to get to a 3.0 you need to make every overhead.",
    "The Overhead 3" => "Great overheads! You are putting a lot away, but as you improve, so will your opponet. They will dig more put aways back, so make sure you stay alter and build the point from a position of control. Focus on placement until you've earned the final put away.",
    "The Overhead 2" => "Now that you are making your overheads back, lets work on putting them away. You opponent is going to be on defense here, so focus on hitting the ball where they are not as they back pedal. Of course, you need to make them, so don't over hit - and always expect the next ball to come back. This is pickleball after all!"
  }

  def initialize(module_name)
    @module_name = module_name
  end

  def fetch_description
    DESCRIPTION_HASH[module_name]
  end
end
