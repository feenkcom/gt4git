Class {
	#name : #GtGitDefinitionsListReader,
	#superclass : #GtGitDefinitionsReader,
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsListReader >> create [

	^ BrTagger new
		  aptitude: (BrGlamorousTaggerAptitude new
				   margin: self margin;
				   tagLabel: [ :aTaggerTag | 
					   BrEditor new
						   beReadOnlyWithoutSelection;
						   text: aTaggerTag name;
						   fitContent;
						   aptitude: lookStencil create;
						   focusability: BlFocusability none;
						   yourself ];
				   yourself);
		  namedTags: self getValue
]
