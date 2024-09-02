Extension { #name : #PureGitRepository }

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtBranchesFor: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Branches';
		priority: 35;
		items: [ self allBranches ];
		column: 'Name' text: [ :branch | branch name ];
		column: 'Type' text: [ :branch | branch branchType ];
		column: 'Commit' text: [ :branch | branch commitId ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetails [
	| details |
	details := {
		{ 'location' . self location ifNil: [ 'not set' ] . self location }.
		{ 'exists' . self exists }
	}.
	self exists
		ifTrue: [
			details := details , {
				{ 'HEAD' . self head commitId . self head }
			} ].
	^ details
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ self gtDetails ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtLogFor: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit id ];
		column: 'Timestamp' text: [ :commit | commit timestamp ];
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtTagsFor: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Tags';
		priority: 40;
		items: [ self tags ];
		column: 'Name' text: [ :tag | tag name ];
		column: 'Commit' text: [ :tag | tag commitId ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository class >> gtViewGitCallsIn: composite [
	<gtClassView>
	
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ 
			( (#runGitWithArgs: gtReferences & #gtViewGitCallsIn: gtImplementors not)
					& 'PureGitRepository' gtClassMatches) contents
				 sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
]
