Extension { #name : #PureGitCommandLineInterface }

{ #category : #'*GToolkit4Git' }
PureGitCommandLineInterface class >> gtViewGitCallsIn: composite [
	<gtClassView>
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ | selectors |
			selectors := 
				( ((#runGitWithArgs: gtReferences
						| #runGitWithArgsAsync: gtReferences) 
					& #gtViewGitCallsIn: gtImplementors not)
						& self name gtClassMatches) contents.
			(self includesSelector: #contentsOfBlob:)
				ifTrue: [ selectors := selectors copyWith: self >> #contentsOfBlob: ].
			selectors sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
]
