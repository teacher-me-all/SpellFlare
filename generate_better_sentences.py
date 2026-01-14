#!/usr/bin/env python3
"""
Generate improved, contextual sentences for spelling bee words.
Sentences provide information about the word and help with comprehension.
"""

import json

# Better sentences that provide context and meaning
IMPROVED_SENTENCES = {
    # Grade 1 (Difficulty 1)
    "cat": [
        "A cat is a small furry animal that purrs and meows.",
        "Cats have whiskers that help them sense things around them.",
        "Many families keep a cat as a pet because they are gentle."
    ],
    "dog": [
        "A dog is a loyal animal that can be trained to do tricks.",
        "Dogs bark to communicate and protect their homes.",
        "Many dogs love to play fetch and go for walks with their owners."
    ],
    "sun": [
        "The sun is a giant star that gives us light and warmth.",
        "Plants need the sun to grow and make food.",
        "The sun rises in the east every morning and sets in the west."
    ],
    "run": [
        "When you run, you move your legs very fast to go quickly.",
        "Athletes train hard to run faster in races.",
        "Children love to run and play tag during recess."
    ],
    "big": [
        "When something is big, it means it takes up a lot of space.",
        "Elephants are big animals that can weigh several tons.",
        "You need a big box to pack all your toys."
    ],
    "red": [
        "Red is a bright color like apples, fire trucks, and roses.",
        "Stop signs are red to warn drivers to stop their cars.",
        "When you mix red and yellow paint, you get orange."
    ],
    "hot": [
        "Something that is hot has a high temperature and can burn you.",
        "The stove gets hot when you cook food on it.",
        "In summer, the weather is hot and people go swimming to cool off."
    ],
    "pet": [
        "A pet is an animal that lives with you and becomes part of your family.",
        "Taking care of a pet teaches children responsibility.",
        "Dogs, cats, and fish are popular pets that people love."
    ],
    "fun": [
        "When something is fun, it makes you happy and you enjoy it.",
        "Playing games with friends is a fun way to spend time.",
        "Learning can be fun when teachers make it exciting."
    ],
    "top": [
        "The top is the highest part of something.",
        "Climbers work hard to reach the top of a mountain.",
        "Put a hat on top of your head to protect it from the sun."
    ],
    "sit": [
        "When you sit, you rest your body on a chair or the ground.",
        "Students sit at desks while they study in class.",
        "It's good to sit up straight to keep your back healthy."
    ],
    "box": [
        "A box is a container with four sides and a lid.",
        "Moving companies use boxes to pack and transport belongings.",
        "A jewelry box keeps your precious rings and necklaces safe."
    ],
    "hat": [
        "A hat is something you wear on your head for protection or style.",
        "Baseball players wear hats to keep the sun out of their eyes.",
        "In winter, a warm hat helps prevent heat from escaping your body."
    ],
    "cup": [
        "A cup is a small container used for drinking liquids.",
        "Pour milk into a cup when you want to drink it.",
        "A measuring cup helps you follow recipes when baking."
    ],
    "bed": [
        "A bed is furniture where you lie down to sleep and rest.",
        "Getting enough sleep in a comfortable bed keeps you healthy.",
        "Make your bed every morning to keep your room neat."
    ],
    "bus": [
        "A bus is a large vehicle that carries many passengers together.",
        "School buses take children safely to and from school each day.",
        "Public buses help people travel around cities without needing cars."
    ],
    "mom": [
        "Mom is a short word for mother, the parent who gave birth to you.",
        "Moms take care of their children and help them grow strong.",
        "Many people celebrate mothers on Mother's Day in May."
    ],
    "dad": [
        "Dad is a short word for father, one of your parents.",
        "Dads work hard to support and protect their families.",
        "Father's Day is a special time to thank your dad."
    ],
    "fox": [
        "A fox is a wild animal with reddish fur and a bushy tail.",
        "Foxes are clever hunters that live in forests and fields.",
        "The phrase sly as a fox means someone is very clever."
    ],
    "yes": [
        "Yes is a word you say when you agree or accept something.",
        "Saying yes shows you are willing to do what someone asked.",
        "When the teacher asks if you understand, you can nod or say yes."
    ],

    # Grade 2 (Difficulty 2)
    "apple": [
        "An apple is a round fruit that grows on trees and is full of vitamins.",
        "Apples can be red, green, or yellow and taste sweet or tart.",
        "The saying an apple a day keeps the doctor away means apples are healthy."
    ],
    "ball": [
        "A ball is a round object used in many sports and games.",
        "Basketballs, soccer balls, and baseballs have different sizes and uses.",
        "The shape of a ball is called a sphere in geometry."
    ],
    "bird": [
        "A bird is an animal with feathers, wings, and a beak that lays eggs.",
        "Most birds can fly by flapping their wings through the air.",
        "Birds sing beautiful songs, especially in the morning."
    ],
    "blue": [
        "Blue is the color of the sky on a clear day and the deep ocean.",
        "When you mix blue and yellow paint together, you create green.",
        "Many police officers and security guards wear blue uniforms."
    ],
    "book": [
        "A book contains pages with words and pictures that tell stories or teach facts.",
        "Reading books helps you learn new things and improves your imagination.",
        "Libraries have thousands of books you can borrow for free."
    ],
    "cake": [
        "A cake is a sweet baked dessert made with flour, eggs, and sugar.",
        "People often have birthday cakes with candles to celebrate special days.",
        "Baking a cake requires following a recipe carefully."
    ],
    "dream": [
        "A dream is a series of pictures and stories that happen in your mind while you sleep.",
        "Scientists study dreams to understand how our brains work at night.",
        "Sometimes dreams feel so real you can't tell them from reality."
    ],
    "fish": [
        "A fish is an animal that lives underwater and breathes through gills.",
        "Fish have scales covering their bodies and fins for swimming.",
        "Oceans, lakes, and rivers are home to thousands of fish species."
    ],
    "green": [
        "Green is the color of grass, leaves, and many vegetables.",
        "Plants are green because of chlorophyll, which helps them make food from sunlight.",
        "Green traffic lights tell drivers it is safe to go forward."
    ],
    "happy": [
        "When you are happy, you feel joyful, pleased, and full of smiles.",
        "Spending time with friends and family often makes people happy.",
        "Happiness is an emotion that makes life more enjoyable."
    ],
    "house": [
        "A house is a building where people live with their families.",
        "Houses protect us from weather and give us a safe place to sleep.",
        "Different cultures build houses in different styles and materials."
    ],
    "jump": [
        "When you jump, you push your feet off the ground and go into the air.",
        "Athletes jump high or far in track and field competitions.",
        "Kangaroos are animals famous for their ability to jump long distances."
    ],
    "light": [
        "Light is energy that lets us see things around us.",
        "The sun is our main source of natural light during daytime.",
        "Electric lights help us see at night when it's dark outside."
    ],
    "mouse": [
        "A mouse is a small rodent with a long tail and tiny paws.",
        "Computer mice help you click and move the cursor on screens.",
        "Cats are natural hunters that chase mice."
    ],
    "play": [
        "When you play, you do activities for fun and enjoyment.",
        "Children learn important skills through play and games.",
        "Actors play characters in movies and theater performances."
    ],
    "sleep": [
        "Sleep is when your body and mind rest during the night.",
        "Getting enough sleep helps you grow, learn, and stay healthy.",
        "Most adults need about eight hours of sleep each night."
    ],
    "smile": [
        "A smile is the happy expression you make with your mouth when pleased.",
        "Smiling at someone can brighten their day and make them feel welcome.",
        "It takes fewer muscles to smile than to frown."
    ],
    "swim": [
        "When you swim, you move through water using your arms and legs.",
        "Learning to swim is an important safety skill everyone should have.",
        "Fish and dolphins are animals perfectly adapted for swimming."
    ],
    "tree": [
        "A tree is a tall plant with a trunk, branches, and leaves.",
        "Trees produce oxygen that we breathe and provide homes for many animals.",
        "Some trees live for hundreds or even thousands of years."
    ],
    "water": [
        "Water is a clear liquid that all living things need to survive.",
        "Earth is covered mostly by water in oceans, lakes, and rivers.",
        "Your body is about sixty percent water, so drink plenty every day."
    ],

    # Grade 3 (Difficulty 3)
    "beach": [
        "A beach is the sandy or rocky shore beside an ocean or lake.",
        "Many families visit beaches in summer to swim and build sandcastles.",
        "Beaches are important habitats for crabs, seabirds, and other wildlife."
    ],
    "bench": [
        "A bench is a long seat where several people can sit together.",
        "Parks have benches where you can rest and enjoy nature.",
        "The carpenter built a wooden bench for the garden."
    ],
    "branch": [
        "A branch is a part of a tree that grows out from the trunk.",
        "Birds build nests on sturdy branches to keep their eggs safe.",
        "The science of biology has many branches, like zoology and botany."
    ],
    "bring": [
        "When you bring something, you carry it with you to a place.",
        "Please bring your homework to class tomorrow morning.",
        "The dark clouds will bring rain later this afternoon."
    ],
    "catch": [
        "When you catch something, you grab it while it's moving through the air.",
        "Baseball players wear gloves to help them catch the ball.",
        "If you go outside without a coat, you might catch a cold."
    ],
    "clean": [
        "When something is clean, it has no dirt or mess on it.",
        "Washing your hands keeps them clean and prevents disease.",
        "The janitor works hard to keep the school clean every day."
    ],
    "cloud": [
        "A cloud is a collection of tiny water droplets floating in the sky.",
        "Different types of clouds can predict what weather is coming.",
        "Clouds look white because they reflect sunlight back to our eyes."
    ],
    "crunch": [
        "Crunch is the sound made when you bite hard or crispy food.",
        "You can hear the crunch when you step on dry autumn leaves.",
        "Apples and carrots make a satisfying crunch when you eat them."
    ],
    "french": [
        "French is a language spoken in France and many other countries.",
        "Learning French can help you communicate when traveling in Europe.",
        "French fries and French toast are popular foods named after the country."
    ],
    "friend": [
        "A friend is someone who likes you and enjoys spending time with you.",
        "Good friends are kind, honest, and help each other through difficult times.",
        "Making friends at school makes learning more fun and enjoyable."
    ],
    "laugh": [
        "When you laugh, you make sounds showing something is funny or joyful.",
        "Laughing is good for your health and makes you feel happy.",
        "Comedians tell jokes to make their audiences laugh out loud."
    ],
    "lunch": [
        "Lunch is the meal you eat in the middle of the day.",
        "Eating a healthy lunch gives you energy for afternoon activities.",
        "Many schools provide lunch programs to help feed students."
    ],
    "match": [
        "A match is a small stick that creates fire when you strike it.",
        "In sports, a match is a competition between two teams or players.",
        "These socks match because they are the same color and pattern."
    ],
    "patch": [
        "A patch is a piece of material used to cover a hole or damage.",
        "Farmers grow vegetables in small patches of their gardens.",
        "The doctor put a patch over the cut to keep it clean."
    ],
    "plant": [
        "A plant is a living thing that grows in soil and makes its own food.",
        "Plants need water, sunlight, and air to survive and grow strong.",
        "Factories and facilities are sometimes called plants, like power plants."
    ],
    "school": [
        "School is a place where teachers help students learn new things.",
        "Going to school prepares you for future jobs and opportunities.",
        "There are many types of schools, including elementary, middle, and high school."
    ],
    "thing": [
        "A thing is any object, idea, or matter you can talk about.",
        "Scientists study how things in nature work and interact.",
        "Sometimes it's hard to describe a thing when you don't know its name."
    ],
    "train": [
        "A train is a vehicle with many cars that runs on railroad tracks.",
        "Trains can carry hundreds of passengers or tons of cargo long distances.",
        "To train means to practice and learn skills to get better at something."
    ],
    "watch": [
        "When you watch something, you look at it carefully with your eyes.",
        "A watch is a small clock you wear on your wrist to tell time.",
        "Security guards watch buildings to protect them from danger."
    ],
    "write": [
        "When you write, you use letters and words to communicate on paper or screen.",
        "Authors write books, stories, and poems to entertain and inform readers.",
        "Learning to write clearly is an important skill for success in life."
    ],

    # Grade 4 (Difficulty 4)
    "another": [
        "Another means one more of the same kind or a different one.",
        "If you're still hungry, you can have another slice of pizza.",
        "After finishing one book, she immediately started reading another."
    ],
    "beautiful": [
        "Something beautiful is very pleasing to look at or experience.",
        "The sunset painted the sky with beautiful shades of orange and pink.",
        "Beautiful music can touch your emotions and bring tears to your eyes."
    ],
    "between": [
        "Between means in the space or time separating two things.",
        "The library is located between the post office and the grocery store.",
        "You must choose between studying now or playing video games later."
    ],
    "bought": [
        "Bought is the past tense of buy, meaning you paid money for something.",
        "She bought new shoes at the mall last Saturday afternoon.",
        "The company bought the building and will renovate it next year."
    ],
    "brought": [
        "Brought is the past tense of bring, meaning you carried something to a place.",
        "He brought his guitar to the party and played songs for everyone.",
        "The storm brought heavy rain and strong winds to our town."
    ],
    "caught": [
        "Caught is the past tense of catch, meaning you grabbed or captured something.",
        "The goalkeeper caught the soccer ball before it went into the net.",
        "Scientists caught the rare butterfly to study its unique wing patterns."
    ],
    "daughter": [
        "A daughter is a female child in relation to her parents.",
        "Parents teach their daughters to be confident and independent.",
        "She is the youngest daughter in a family of five children."
    ],
    "different": [
        "When things are different, they are not the same or alike.",
        "Every snowflake has a different pattern, making each one unique.",
        "People come from different backgrounds and cultures around the world."
    ],
    "fought": [
        "Fought is the past tense of fight, meaning battled or struggled against something.",
        "The soldiers fought bravely to protect their country from invasion.",
        "She fought hard to overcome her fear of public speaking."
    ],
    "height": [
        "Height is how tall something or someone is from bottom to top.",
        "Mountain climbers must adjust to the height as oxygen becomes thinner.",
        "The doctor measures your height every year to track your growth."
    ],
    "important": [
        "Something important matters a great deal and deserves attention.",
        "Drinking water and eating healthy food are important for your body.",
        "Scientists made an important discovery that could help cure diseases."
    ],
    "neighbor": [
        "A neighbor is someone who lives near you in the surrounding area.",
        "Good neighbors help each other and keep their community safe.",
        "Our neighbor grows beautiful roses in her front garden."
    ],
    "remember": [
        "When you remember something, you keep it in your mind and can recall it.",
        "I remember my first day of school because it was very exciting.",
        "Please remember to bring your permission slip tomorrow."
    ],
    "sought": [
        "Sought is the past tense of seek, meaning searched for or tried to find.",
        "The explorer sought treasure hidden deep in the ancient temple.",
        "She sought advice from her teacher about which college to attend."
    ],
    "straight": [
        "Something straight goes in one direction without bending or curving.",
        "Draw a straight line using a ruler to connect these two points.",
        "She sat up straight in her chair to show the judge she was paying attention."
    ],
    "taught": [
        "Taught is the past tense of teach, meaning instructed or educated someone.",
        "My grandmother taught me how to knit warm scarves and hats.",
        "The coach taught the team new strategies to improve their game."
    ],
    "thought": [
        "Thought is the past tense of think, or an idea in your mind.",
        "She thought carefully before answering the difficult question.",
        "Scientists believe that language helps organize our thoughts."
    ],
    "through": [
        "Through means from one end or side to the other.",
        "The train goes through a long tunnel beneath the mountain.",
        "We learned about multiplication through fun games and activities."
    ],
    "together": [
        "Together means with each other or in the same place at the same time.",
        "Working together as a team helps us accomplish more than working alone.",
        "The family decided to stay together during the difficult times."
    ],
    "weight": [
        "Weight is how heavy something is when pulled by gravity.",
        "Astronauts experience less weight when they travel to the moon.",
        "The weight of an object depends on its mass and gravitational force."
    ],

    # Grade 5 (Difficulty 5) - More advanced contextual sentences
    "adventure": [
        "An adventure is an exciting experience that often involves risk or discovery.",
        "Reading adventure stories can transport you to far-away lands and different times.",
        "Life is a grand adventure full of unexpected opportunities and challenges."
    ],
    "attention": [
        "Attention is the focus you give to something with your mind and senses.",
        "Paying attention in class helps you understand and remember what you learn.",
        "Doctors recommend limiting screen time to improve children's attention spans."
    ],
    "celebrate": [
        "To celebrate means to do something special to honor an important event.",
        "Families celebrate birthdays, holidays, and achievements together with joy.",
        "Communities celebrate their history through festivals and cultural events."
    ],
    "character": [
        "A character is a person in a story or the qualities that make someone unique.",
        "The main character in the novel showed courage when facing difficult choices.",
        "Building good character means being honest, kind, and responsible."
    ],
    "community": [
        "A community is a group of people living in the same area or sharing common interests.",
        "Strong communities support their members and work together to solve problems.",
        "Online communities connect people from around the world who share similar hobbies."
    ],
    "continue": [
        "To continue means to keep doing something without stopping.",
        "Even when the task becomes difficult, successful people continue working toward their goals.",
        "The story will continue in the next chapter with more exciting adventures."
    ],
    "describe": [
        "When you describe something, you explain what it looks, sounds, or feels like.",
        "Authors use descriptive words to help readers visualize scenes in their imagination.",
        "Scientists describe their experiments so other researchers can repeat them."
    ],
    "discover": [
        "To discover means to find something for the first time or learn something new.",
        "Explorers discover new lands, while scientists discover how nature works.",
        "You might discover a new favorite book when you visit the library."
    ],
    "education": [
        "Education is the process of learning knowledge and skills through study or experience.",
        "A good education opens doors to better careers and opportunities in life.",
        "Countries invest in education because educated citizens strengthen society."
    ],
    "especially": [
        "Especially means more than usual or particularly in a specific case.",
        "Drinking water is important, especially during hot summer weather.",
        "The museum has many exhibits, but the dinosaur fossils are especially popular."
    ],
    "experience": [
        "Experience is knowledge or skill gained by doing something over time.",
        "Doctors gain experience by treating thousands of patients throughout their careers.",
        "Life experiences shape who we are and how we view the world."
    ],
    "favorite": [
        "Your favorite is the thing you like best among all choices.",
        "Pizza is my favorite food because I love the combination of cheese and sauce.",
        "Having a favorite book often means you've read it multiple times."
    ],
    "government": [
        "A government is the system or group that rules and manages a country.",
        "Democratic governments allow citizens to vote and choose their leaders.",
        "The government creates laws to protect people and maintain order in society."
    ],
    "interested": [
        "When you are interested in something, you want to know more about it.",
        "Students who are interested in science might become doctors or engineers.",
        "Being interested in different cultures helps you understand the world better."
    ],
    "knowledge": [
        "Knowledge is information and understanding you gain through learning and experience.",
        "Libraries preserve knowledge for future generations to study and explore.",
        "Sharing knowledge with others is one of the most valuable gifts you can give."
    ],
    "literature": [
        "Literature refers to written works like novels, poems, and plays considered art.",
        "Studying literature helps us understand different perspectives and time periods.",
        "Shakespeare's literature has influenced writers for over four hundred years."
    ],
    "necessary": [
        "Something necessary is required or essential for a particular purpose.",
        "Water is necessary for all forms of life on Earth to survive.",
        "It's necessary to study if you want to do well on your tests."
    ],
    "paragraph": [
        "A paragraph is a group of sentences about one main idea in writing.",
        "Each paragraph in an essay should support the overall thesis statement.",
        "Starting a new paragraph signals readers that you're introducing a different idea."
    ],
    "particular": [
        "Particular means specific or relating to one individual thing rather than all.",
        "This particular butterfly species only lives in tropical rainforests.",
        "She has a particular interest in astronomy and studies the stars every night."
    ],

    # Grade 6 (Difficulty 6)
    "accomplish": [
        "To accomplish means to successfully complete or achieve a goal.",
        "Athletes must train for years to accomplish their Olympic dreams.",
        "Setting clear goals helps you accomplish what you want in life."
    ],
    "appreciate": [
        "When you appreciate something, you recognize its value or are grateful for it.",
        "Taking time to appreciate nature's beauty can improve your mental health.",
        "Teachers appreciate when students work hard and participate in class."
    ],
    "atmosphere": [
        "The atmosphere is the layer of gases surrounding Earth or the mood of a place.",
        "Earth's atmosphere protects us from harmful radiation and provides oxygen to breathe.",
        "The restaurant had a warm, welcoming atmosphere that made guests feel comfortable."
    ],
    "boundaries": [
        "Boundaries are lines that separate different areas or limits on behavior.",
        "Countries have boundaries that mark where one nation ends and another begins.",
        "Setting personal boundaries helps you maintain healthy relationships with others."
    ],
    "challenge": [
        "A challenge is a difficult task that tests your abilities and skills.",
        "Learning a new language presents a challenge that becomes easier with practice.",
        "Athletes welcome challenges because overcoming them makes them stronger."
    ],
    "commercial": [
        "Commercial refers to business, trade, or advertisements that sell products.",
        "Television networks show commercial breaks to earn money from advertisers.",
        "The commercial district downtown has many stores, offices, and restaurants."
    ],
    "competition": [
        "Competition is when people or groups try to win or be better than others.",
        "Healthy competition in sports teaches valuable lessons about effort and sportsmanship.",
        "Companies face competition in the marketplace to attract customers."
    ],
    "concentrate": [
        "To concentrate means to focus all your attention on one thing.",
        "Students need to concentrate on their work to learn and retain information.",
        "It's difficult to concentrate when there are loud noises or distractions nearby."
    ],
    "conscience": [
        "Your conscience is the inner sense of right and wrong that guides your behavior.",
        "Having a guilty conscience means you feel bad about something you did wrong.",
        "People with a strong conscience try to act honestly and treat others fairly."
    ],
    "consequence": [
        "A consequence is the result or effect that follows from an action or decision.",
        "Every choice has consequences, some positive and others negative.",
        "Understanding the consequences of your actions helps you make better decisions."
    ],
    "consistent": [
        "Being consistent means doing something regularly in the same way over time.",
        "Consistent practice is the key to mastering any musical instrument.",
        "Weather patterns become consistent during certain seasons of the year."
    ],
    "demonstrate": [
        "To demonstrate means to show clearly how something works or is done.",
        "The teacher will demonstrate the science experiment before students try it themselves.",
        "Athletes demonstrate remarkable skill and dedication in their performances."
    ],
    "development": [
        "Development is the process of growing, changing, or creating something new.",
        "Child development experts study how children learn and mature over time.",
        "Technological development has transformed how we communicate and work."
    ],
    "environment": [
        "The environment includes all the natural surroundings where organisms live.",
        "Protecting the environment ensures future generations have clean air and water.",
        "Your home and school environment can affect how you feel and behave."
    ],
    "essentially": [
        "Essentially means basically or in the most important aspects.",
        "Water is essentially two hydrogen atoms bonded to one oxygen atom.",
        "The two plans are essentially the same, with only minor differences."
    ],
    "exaggerate": [
        "To exaggerate means to make something seem larger, better, or worse than it really is.",
        "Some people exaggerate their accomplishments to impress others.",
        "Cartoons often exaggerate features to create humor and visual interest."
    ],
    "explanation": [
        "An explanation is information that makes something clear or easy to understand.",
        "The teacher provided a detailed explanation of how photosynthesis works.",
        "When you make a mistake, offering an honest explanation shows responsibility."
    ],
    "extraordinary": [
        "Something extraordinary is very unusual, remarkable, or beyond what is normal.",
        "The scientist made an extraordinary discovery that changed our understanding of physics.",
        "With extraordinary effort and determination, she achieved what seemed impossible."
    ],
    "fascinating": [
        "Something fascinating is extremely interesting and captures your attention completely.",
        "The documentary about ocean life was fascinating and taught me many new facts.",
        "Historians find it fascinating to study how ancient civilizations lived."
    ],
    "throughout": [
        "Throughout means in every part of something or during the entire time.",
        "The explorers traveled throughout Asia, visiting dozens of countries.",
        "She remained calm and focused throughout the difficult competition."
    ],

    # Grade 7 (Difficulty 7)
    "accommodate": [
        "To accommodate means to provide space for someone or adapt to meet their needs.",
        "Hotels accommodate travelers by providing comfortable rooms and services.",
        "Good teachers accommodate different learning styles to help all students succeed."
    ],
    "achievement": [
        "An achievement is something accomplished successfully through effort and skill.",
        "Graduating from college is a major achievement that requires years of study.",
        "The team celebrated their achievement of winning the championship."
    ],
    "acknowledge": [
        "To acknowledge means to accept or admit that something exists or is true.",
        "Scientists acknowledge that climate change poses serious environmental challenges.",
        "It's important to acknowledge your mistakes and learn from them."
    ],
    "acquaintance": [
        "An acquaintance is someone you know slightly but not as well as a friend.",
        "She has many acquaintances from work but only a few close friends.",
        "Building acquaintances in your field can lead to future career opportunities."
    ],
    "advertisement": [
        "An advertisement is a notice or announcement promoting a product, service, or event.",
        "Companies spend billions on advertisements to persuade customers to buy their products.",
        "Effective advertisements create memorable messages that influence consumer behavior."
    ],
    "anniversary": [
        "An anniversary marks the date when something important happened in a previous year.",
        "Couples often celebrate their wedding anniversary with a special dinner.",
        "The school's fiftieth anniversary celebration included former students from decades past."
    ],
    "anticipation": [
        "Anticipation is excited expectation about something that's going to happen.",
        "Children wait in anticipation for their birthdays and holidays throughout the year.",
        "The crowd's anticipation grew as the curtain slowly rose before the performance."
    ],
    "appreciation": [
        "Appreciation is recognition and enjoyment of good qualities or grateful acknowledgment.",
        "Art appreciation classes teach students to understand and value different artistic styles.",
        "Showing appreciation for others' help strengthens relationships and builds goodwill."
    ],
    "approximately": [
        "Approximately means close to but not exactly a certain number or amount.",
        "The museum is approximately three miles from the downtown area.",
        "There are approximately seven thousand languages spoken in the world today."
    ],
    "archaeological": [
        "Archaeological relates to the study of human history through excavating ancient sites.",
        "Archaeological evidence reveals how people lived thousands of years ago.",
        "The archaeological dig uncovered pottery, tools, and other artifacts from ancient Rome."
    ],
    "argumentative": [
        "Argumentative means presenting reasons to support or oppose something, or inclined to argue.",
        "Writing an argumentative essay requires supporting your position with strong evidence.",
        "He became argumentative during discussions, always wanting to debate every point."
    ],
    "autobiography": [
        "An autobiography is the story of a person's life written by that person themselves.",
        "Reading autobiographies helps you understand famous people's struggles and successes.",
        "Nelson Mandela's autobiography describes his fight against apartheid in South Africa."
    ],
    "bibliography": [
        "A bibliography is a list of books and sources used in research or writing.",
        "Include a bibliography at the end of your research paper to credit your sources.",
        "Librarians can help you format your bibliography correctly for academic assignments."
    ],
    "characteristic": [
        "A characteristic is a typical feature or quality that identifies something or someone.",
        "Patience is an important characteristic of successful teachers and mentors.",
        "The characteristic stripes of a zebra help scientists identify individual animals."
    ],
    "chronological": [
        "Chronological means arranged in the order that events happened in time.",
        "Historians organize events in chronological order to understand cause and effect.",
        "Your résumé should list your work experience in reverse chronological order."
    ],
    "circumstances": [
        "Circumstances are the conditions and facts connected to an event or situation.",
        "Under normal circumstances, the flight takes about three hours.",
        "She succeeded despite difficult circumstances that would have discouraged others."
    ],
    "classification": [
        "Classification is the process of arranging things into groups based on shared characteristics.",
        "The classification of living organisms helps biologists understand relationships between species.",
        "Librarians use classification systems to organize books so readers can find them easily."
    ],
    "collaboration": [
        "Collaboration is working together with others toward a common goal or purpose.",
        "Scientific collaboration between countries leads to important discoveries and innovations.",
        "The project's success resulted from effective collaboration among team members."
    ],
    "commemorate": [
        "To commemorate means to honor and remember an important person, event, or achievement.",
        "Statues and monuments commemorate historical figures and significant battles.",
        "The ceremony will commemorate the volunteers who helped during the emergency."
    ],
    "communication": [
        "Communication is the exchange of information, ideas, or feelings between people.",
        "Effective communication requires both clear speaking and active listening skills.",
        "Modern technology has revolutionized global communication through instant messaging."
    ],

    # Grade 8 (Difficulty 8)
    "abbreviation": [
        "An abbreviation is a shortened form of a word or phrase.",
        "Common abbreviations like Dr. for Doctor and St. for Street save writing space.",
        "Text messages often use abbreviations to communicate quickly on mobile devices."
    ],
    "acceleration": [
        "Acceleration is the rate at which velocity changes or the act of speeding up.",
        "Physics students calculate acceleration by measuring changes in speed over time.",
        "The car's rapid acceleration pushed passengers back in their seats."
    ],
    "accessibility": [
        "Accessibility means how easy it is for everyone, including those with disabilities, to use something.",
        "Modern buildings include ramps and elevators to improve accessibility for wheelchair users.",
        "Website accessibility ensures that people with visual impairments can navigate online content."
    ],
    "accomplishment": [
        "An accomplishment is something successfully completed, especially through skill or effort.",
        "Climbing Mount Everest is considered one of mountaineering's greatest accomplishments.",
        "List your academic accomplishments when applying for college scholarships."
    ],
    "accountability": [
        "Accountability means being responsible for your actions and accepting the consequences.",
        "Government accountability ensures elected officials act in the public's best interest.",
        "Taking accountability for mistakes demonstrates maturity and integrity."
    ],
    "acknowledgement": [
        "Acknowledgement is recognition or acceptance of something's existence, validity, or truth.",
        "Authors include acknowledgements thanking those who helped with their books.",
        "Acknowledgement of different perspectives improves understanding in debates."
    ],
    "administration": [
        "Administration is the management and organization of a business, school, or government.",
        "Hospital administration coordinates staff, resources, and patient care services.",
        "The school administration makes important decisions about curriculum and policies."
    ],
    "alphabetically": [
        "Alphabetically means arranged in the order of the alphabet from A to Z.",
        "Dictionaries organize words alphabetically so you can find definitions quickly.",
        "Libraries arrange fiction books alphabetically by the author's last name."
    ],
    "announcements": [
        "Announcements are official statements or notices giving information about something.",
        "The principal makes daily announcements about school events over the intercom.",
        "Companies issue press announcements to inform the public about important developments."
    ],
    "assassination": [
        "Assassination is the murder of someone important for political or religious reasons.",
        "The assassination of President Lincoln shocked the nation during the Civil War.",
        "History books examine how assassinations have changed the course of nations."
    ],
    "authentication": [
        "Authentication is the process of proving that something or someone is genuine or valid.",
        "Two-factor authentication adds extra security to your online accounts.",
        "Museums use scientific authentication to verify that artworks are not forgeries."
    ],
    "biodegradable": [
        "Biodegradable materials can be broken down naturally by bacteria and other organisms.",
        "Biodegradable packaging reduces environmental pollution compared to plastic waste.",
        "Composting works because food scraps are biodegradable and decompose into nutrients."
    ],
    "characteristics": [
        "Characteristics are distinctive qualities or features that describe something or someone.",
        "Different dog breeds have characteristics like size, coat type, and temperament.",
        "Scientists identify species by examining their physical and behavioral characteristics."
    ],
    "circumference": [
        "Circumference is the distance around the outside of a circle or sphere.",
        "To calculate a circle's circumference, multiply its diameter by pi.",
        "Earth's circumference at the equator is approximately twenty-five thousand miles."
    ],
    "commercialize": [
        "To commercialize means to manage or exploit something primarily for profit.",
        "Companies commercialize inventions by manufacturing and selling them to consumers.",
        "Some worry that commercializing holidays focuses too much on shopping."
    ],
    "comprehensive": [
        "Comprehensive means including or dealing with all or nearly all elements of something.",
        "A comprehensive medical exam checks many aspects of your health.",
        "The textbook provides a comprehensive overview of American history."
    ],

    # Grades 9-12 (Difficulties 9-12) - College-prep vocabulary
    "accommodation": [
        "Accommodation refers to lodging and food provided or the process of adapting to needs.",
        "The university provides accommodation for international students in campus dormitories.",
        "Reasonable accommodations help employees with disabilities perform their jobs effectively."
    ],
    "acknowledgment": [
        "Acknowledgment is acceptance of truth or recognition of services or achievements.",
        "The scientist received widespread acknowledgment for her groundbreaking research.",
        "Academic papers require acknowledgment of all sources through proper citations."
    ],
    "approximately": [
        "Approximately indicates a close estimate rather than an exact measurement.",
        "The archaeological site dates back approximately three thousand years.",
        "Approximately seventy percent of Earth's surface is covered by water."
    ],
    "confederation": [
        "A confederation is a union of groups or states that work together while keeping independence.",
        "The Articles of Confederation created America's first national government.",
        "Labor unions form confederations to increase their collective bargaining power."
    ],
    "conscientious": [
        "Conscientious means being careful, thorough, and guided by a sense of right and wrong.",
        "Conscientious students double-check their work before submitting assignments.",
        "Medical professionals must be conscientious in following safety protocols."
    ],
    "correspondence": [
        "Correspondence is communication by letters or emails, or a similarity between things.",
        "Business correspondence should maintain a professional tone and clear purpose.",
        "There is close correspondence between the experimental results and theoretical predictions."
    ],
    "discrimination": [
        "Discrimination is unfair treatment of people based on characteristics like race or gender.",
        "Laws prohibit discrimination in employment, housing, and public services.",
        "Fighting discrimination requires education, policy changes, and cultural awareness."
    ],
    "electromagnetic": [
        "Electromagnetic relates to both electricity and magnetism or their interaction.",
        "Electromagnetic waves include radio waves, visible light, and X-rays.",
        "Modern communication relies on electromagnetic technology like cell phones and WiFi."
    ],
    "entrepreneurial": [
        "Entrepreneurial describes the innovative, risk-taking qualities of business founders.",
        "An entrepreneurial mindset involves identifying opportunities and creating solutions.",
        "Many successful companies began with entrepreneurial individuals and small investments."
    ],
    "environmental": [
        "Environmental relates to the natural world and the impact of human activity on it.",
        "Environmental science studies ecosystems, pollution, and conservation strategies.",
        "Governments create environmental regulations to protect air and water quality."
    ],
    "fundamentalism": [
        "Fundamentalism is strict adherence to basic religious principles or literal interpretations.",
        "Religious fundamentalism emphasizes traditional values and scriptural authority.",
        "Political movements sometimes adopt fundamentalism by rejecting compromise or moderation."
    ],
    "hallucination": [
        "A hallucination is seeing, hearing, or sensing something that isn't actually there.",
        "High fever can sometimes cause hallucinations in sick patients.",
        "Psychologists study hallucinations to understand perception and brain function."
    ],
    "hospitalization": [
        "Hospitalization is the admission and treatment of a patient in a hospital.",
        "Insurance policies often cover hospitalization costs for major medical procedures.",
        "Advances in medicine have reduced hospitalization time for many surgeries."
    ],
    "hypothetically": [
        "Hypothetically means based on a suggested idea rather than proven facts.",
        "Hypothetically speaking, if you won the lottery, how would you spend the money?",
        "Scientists reason hypothetically to develop theories before conducting experiments."
    ],
    "identification": [
        "Identification is recognizing or establishing who or what something is.",
        "Proper identification is required for voting, banking, and air travel.",
        "Fingerprint identification has been used in law enforcement for over a century."
    ],
    "implementation": [
        "Implementation is putting a plan, decision, or system into effect.",
        "Successful implementation of new policies requires training and adequate resources.",
        "Software implementation involves installing, configuring, and testing programs."
    ],
    "impressionable": [
        "Impressionable describes someone easily influenced because of youth or inexperience.",
        "Young children are impressionable and learn behaviors by watching adults.",
        "Advertisers target impressionable audiences who might adopt their suggested lifestyles."
    ],
    "incomprehensible": [
        "Incomprehensible means impossible or extremely difficult to understand.",
        "Advanced mathematics can seem incomprehensible without proper background knowledge.",
        "The professor's handwriting was so messy it was nearly incomprehensible."
    ],
    "individualism": [
        "Individualism is the belief in personal independence and individual rights over collective goals.",
        "American culture traditionally emphasizes individualism and self-reliance.",
        "Philosophers debate the balance between individualism and social responsibility."
    ],
    "industrialization": [
        "Industrialization is the development of industries on a large scale in a region.",
        "The Industrial Revolution brought rapid industrialization to Europe and America.",
        "Industrialization transformed agricultural societies into urban manufacturing centers."
    ],
    "infrastructure": [
        "Infrastructure includes basic physical systems like roads, bridges, and utilities.",
        "Governments invest in infrastructure to support economic growth and quality of life.",
        "Modern infrastructure must incorporate digital networks and renewable energy systems."
    ],
    "institutionalize": [
        "To institutionalize means to establish something as a convention or norm in an organization.",
        "Schools institutionalize learning standards through curriculum and assessment.",
        "Democratic societies institutionalize rights through constitutions and legal systems."
    ],
    "instrumentation": [
        "Instrumentation refers to instruments used for measurement or the arrangement of music.",
        "Scientific instrumentation has become increasingly sophisticated and precise.",
        "The orchestra's instrumentation included strings, brass, woodwinds, and percussion."
    ],
    "intellectualism": [
        "Intellectualism emphasizes the importance of reason and theoretical knowledge.",
        "Academic intellectualism values research, critical thinking, and scholarly discourse.",
        "Some criticize excessive intellectualism for being disconnected from practical concerns."
    ],
    # Grade 11 (Difficulty 11)
    "acknowledgeable": [
        "Acknowledgeable means capable of being recognized, accepted, or admitted as valid.",
        "The defendant's acknowledgeable guilt led to a plea bargain agreement.",
        "Historical records provide acknowledgeable evidence of past civilizations."
    ],
    "characterization": [
        "Characterization is the description of distinctive qualities or portrayal in literature.",
        "Strong characterization makes fictional people seem real and believable to readers.",
        "The actor's characterization of the villain was both terrifying and sympathetic."
    ],
    "circumstantial": [
        "Circumstantial describes evidence suggesting something but not proving it directly.",
        "The lawyer argued that circumstantial evidence alone cannot support a conviction.",
        "Circumstantial factors like weather and traffic affected the project timeline."
    ],
    "commercialization": [
        "Commercialization is the process of introducing new products into the marketplace.",
        "The commercialization of space travel could make it accessible to ordinary citizens.",
        "Critics worry about the commercialization of education through profit-driven schools."
    ],
    "compartmentalize": [
        "To compartmentalize means to divide into separate sections or mental categories.",
        "People often compartmentalize work and personal life to maintain balance.",
        "Psychologists study how individuals compartmentalize traumatic experiences."
    ],
    "comprehensibility": [
        "Comprehensibility is the quality of being understandable or intelligible.",
        "Teachers work to improve the comprehensibility of complex scientific concepts.",
        "Translation software has improved but still struggles with full comprehensibility."
    ],
    "conceptualization": [
        "Conceptualization is forming an abstract idea or mental representation of something.",
        "Architectural conceptualization transforms client needs into building designs.",
        "Scientific conceptualization involves creating theoretical models to explain phenomena."
    ],
    "confidentiality": [
        "Confidentiality means keeping information private and not sharing it without permission.",
        "Medical confidentiality protects patient privacy and builds trust in healthcare.",
        "Legal confidentiality allows clients to speak freely with their attorneys."
    ],
    "congratulations": [
        "Congratulations are expressions of praise and joy for someone's achievement.",
        "Congratulations on your graduation after years of hard work and dedication!",
        "The team received congratulations from fans worldwide after winning the championship."
    ],
    "conscientiously": [
        "Conscientiously means doing something carefully, thoroughly, and responsibly.",
        "She conscientiously reviewed every detail before submitting the important report.",
        "Healthcare workers conscientiously follow safety protocols to protect patients."
    ],
    "constitutionality": [
        "Constitutionality is the quality of being in accordance with a constitution.",
        "Courts determine the constitutionality of laws through judicial review.",
        "Debates about constitutionality often involve fundamental questions of rights and powers."
    ],
    "contemporaneous": [
        "Contemporaneous means existing or occurring in the same period of time.",
        "Archaeologists study contemporaneous civilizations to understand cultural exchanges.",
        "The two artists were contemporaneous but developed very different styles."
    ],
    "conventionalize": [
        "To conventionalize means to make something follow accepted standards or norms.",
        "Language naturally conventionalizes as communities agree on word meanings.",
        "Artists sometimes conventionalize symbols to make them universally recognizable."
    ],
    "counterproductive": [
        "Counterproductive means having the opposite of the desired effect.",
        "Punishment without explanation can be counterproductive in teaching children.",
        "Working excessive hours is often counterproductive because fatigue reduces quality."
    ],
    "crystallization": [
        "Crystallization is the formation of crystals or the process of making ideas clear.",
        "Salt crystallization occurs when seawater evaporates leaving solid crystals behind.",
        "The crystallization of her thoughts led to a breakthrough in solving the problem."
    ],
    "decentralization": [
        "Decentralization is distributing power away from a single central authority.",
        "Government decentralization can improve local responsiveness to community needs.",
        "Cryptocurrency uses decentralization to operate without central banking control."
    ],
    "demilitarization": [
        "Demilitarization is the reduction or removal of military forces and weapons.",
        "Peace treaties often include demilitarization of border regions.",
        "The demilitarization zone between the two countries reduced tensions."
    ],
    "democratization": [
        "Democratization is the introduction of democratic principles or making something accessible to all.",
        "The internet's democratization of information has transformed how people learn.",
        "Many nations underwent democratization in the late twentieth century."
    ],
    "departmentalize": [
        "To departmentalize means to divide into specialized departments or categories.",
        "Large corporations departmentalize operations to improve efficiency and expertise.",
        "Universities departmentalize academic disciplines to organize faculty and curriculum."
    ],

    # Grade 12 (Difficulty 12)
    "autobiographical": [
        "Autobiographical means relating to the story of one's own life written by oneself.",
        "Many novels contain autobiographical elements drawn from the author's experiences.",
        "Her autobiographical essay revealed personal struggles that shaped her philosophy."
    ],
    "characteristically": [
        "Characteristically means in a way that is typical of a person or thing.",
        "He characteristically arrived early and prepared thoroughly for every meeting.",
        "The artist characteristically used bold colors and geometric shapes in her paintings."
    ],
    "compartmentalization": [
        "Compartmentalization is the mental separation of conflicting thoughts or the division into sections.",
        "Extreme compartmentalization can prevent people from seeing connections between issues.",
        "Organizational compartmentalization sometimes creates communication barriers between departments."
    ],
    "comprehensively": [
        "Comprehensively means in a way that includes all or nearly all elements thoroughly.",
        "The textbook covers world history comprehensively from ancient times to present.",
        "Insurance policies should be reviewed comprehensively before signing the contract."
    ],
    "confidentiality": [
        "Confidentiality means keeping sensitive information private and protected from disclosure.",
        "Attorney-client confidentiality allows legal representation without fear of revelation.",
        "Medical confidentiality builds trust essential for honest patient-doctor communication."
    ],
    "congratulatory": [
        "Congratulatory means expressing praise and happiness for someone's success.",
        "She received congratulatory messages from colleagues worldwide after her promotion.",
        "The congratulatory tone of the letter reflected genuine admiration for his achievements."
    ],
    "constitutionally": [
        "Constitutionally means according to a constitution or in terms of one's physical makeup.",
        "The law was ruled constitutionally valid by the Supreme Court.",
        "Some people are constitutionally unable to tolerate certain medications."
    ],
    "contemporaneously": [
        "Contemporaneously means happening or existing during the same period of time.",
        "Multiple revolutions occurred contemporaneously across Europe in the 1840s.",
        "The witness testified that two events happened contemporaneously making causation unclear."
    ],
    "conventionally": [
        "Conventionally means in a way that follows accepted customs, practices, or standards.",
        "Tomatoes are conventionally considered vegetables in cooking but botanically are fruits.",
        "The building was conventionally designed without innovative architectural features."
    ],
    "correspondingly": [
        "Correspondingly means in a way that is similar, equivalent, or directly related.",
        "As temperatures rise, ice sheets melt correspondingly affecting sea levels.",
        "Increased investment in education should correspondingly improve economic outcomes."
    ],
    "counterproductively": [
        "Counterproductively means in a manner that produces the opposite of the intended result.",
        "Micromanaging employees often works counterproductively by reducing motivation.",
        "The medication counterproductively worsened the symptoms it was meant to treat."
    ],
    "crystallographic": [
        "Crystallographic relates to the study of crystal structure and formation.",
        "Crystallographic analysis reveals how atoms arrange themselves in minerals.",
        "Scientists use crystallographic techniques to understand molecular structures in proteins."
    ],
    "decentralization": [
        "Decentralization is the distribution of administrative powers away from central authority.",
        "Political decentralization can empower local governments to address regional issues.",
        "Blockchain technology represents financial decentralization through distributed ledgers."
    ],
    "demilitarization": [
        "Demilitarization is the process of reducing or eliminating military presence and capabilities.",
        "Post-war demilitarization transformed former military bases into civilian spaces.",
        "The treaty called for complete demilitarization of the disputed territory."
    ],
    "democratization": [
        "Democratization is extending democratic principles or making resources widely available.",
        "Technology's democratization of education provides learning opportunities globally.",
        "The democratization of publishing through the internet empowers diverse voices."
    ],
    "departmentalization": [
        "Departmentalization is organizing a complex system into specialized functional units.",
        "Business departmentalization separates marketing, finance, operations, and human resources.",
        "Hospital departmentalization organizes medical specialties for efficient patient care."
    ],
    "deterministically": [
        "Deterministically means in a way assuming that events are predetermined by prior causes.",
        "The physicist explained how particles behave deterministically according to natural laws.",
        "Deterministically viewing history ignores the role of chance and human choice."
    ],
    "developmentally": [
        "Developmentally means relating to the process of growth and maturation over time.",
        "Children learn language skills according to developmentally appropriate stages.",
        "Curriculum should be developmentally suitable for students' cognitive abilities."
    ]
}

def main():
    print("🎨 Generating improved contextual sentences...")
    print(f"📝 Total words to process: {len(IMPROVED_SENTENCES)}")

    # Load the original file to get structure
    with open("SENTENCES_AUDIO_BATCH.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    # Update sentences with improved versions
    updated_count = 0
    for sentence in data["sentences"]:
        word = sentence["word"]
        if word in IMPROVED_SENTENCES:
            sentence_num = sentence["sentenceNumber"]
            sentence["text"] = IMPROVED_SENTENCES[word][sentence_num - 1]
            updated_count += 1

    # Save improved sentences
    with open("SENTENCES_AUDIO_BATCH_IMPROVED.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Updated {updated_count} sentences")
    print(f"💾 Saved to: SENTENCES_AUDIO_BATCH_IMPROVED.json")
    print()
    print("Next steps:")
    print("1. Review the improved sentences")
    print("2. Run: mv SENTENCES_AUDIO_BATCH_IMPROVED.json SENTENCES_AUDIO_BATCH.json")
    print("3. Regenerate audio: python3 generate_audio_simple.py")

if __name__ == "__main__":
    main()
