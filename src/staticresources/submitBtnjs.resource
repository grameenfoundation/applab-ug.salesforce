 function getGroupString(groupArray) {
               
                 var gString = '';
                 for (var i=0; i<groupArray.length; i++) {
                   groupString = groupString + groupArray[i] + ',';
                 }
                 return groupString = groupString.substring(0, groupString.lastIndexOf(",")); 
            
}

function getPeopleString(peopleArray) {
                
                 var pString = '';
                 for (var j=0; j<peopleArray.length; j++) {
                   peopleString = peopleString + peopleArray[j] + ',';
                 }
                 return peopleString = peopleString.substring(0, peopleString.lastIndexOf(","));              
             
 
}

