//  | # COPYRIGHT HEADER START # 
// |   PasswdLDAP is a Sinatra App that allows users to change their OpenLDAP Password
// |   Copyright (C) 2012 Puzzle ITC GmbH www.puzzle.ch
// |   
// |   This program is free software: you can redistribute it and/or modify
// |   it under the terms of the GNU Affero General Public License as
// |   published by the Free Software Foundation, either version 3 of the
// |   License, or (at your option) any later version.
// |   
// |   This program is distributed in the hope that it will be useful,
// |   but WITHOUT ANY WARRANTY; without even the implied warranty of
// |   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// |   GNU Affero General Public License for more details.
// |   
// |   You should have received a copy of the GNU Affero General Public License
// |   along with this program.  If not, see <http://www.gnu.org/licenses/>.
// | # COPYRIGHT HEADER END # 
 

$(document).ready( function() {
 
			 $(".password_check").passStrength({
					shortPass: 		"top_shortPass",
					badPass:		"top_badPass",
					goodPass:		"top_goodPass",
					strongPass:		"top_strongPass",
					baseStyle:		"top_testresult",
					userid:			"#user_id",
					messageloc:		0
				});
});
