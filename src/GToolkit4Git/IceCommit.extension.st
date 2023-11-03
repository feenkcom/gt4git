Extension { #name : #IceCommit }

{ #category : #'*GToolkit4Git' }
IceCommit >> gtCommitAncestorsDominanceTreeFor: aView [
	"<gtView>"
	^ aView mondrian
		title: 'DominanceTree';
		priority: 60;
		painting: [ :view | 
			view nodes 
				stencil: [ :each |
					| element |
					element := BlElement new.
					element 	
						geometry: BlEllipseGeometry new;
						border: (BlBorder paint: Color black width: 1);
						size: 10@10;
						constraintsDo: [ :constraints | constraints padding: (BlInsets all: 5).
					each = self ifTrue: [element background: Color gray] ifFalse: [element background:  Color white]  ].
					element ];
				with: (self withDeepCollect: #ancestors) asSet.
			view edges connectToAll: #ancestors.
			view layout dominanceTree]
]

{ #category : #'*GToolkit4Git' }
IceCommit >> gtCommitAncestorsTreeFor: aView [
	"<gtView>"
	^ aView mondrian
		title: 'Tree';
		priority: 50;
		painting: [ :view | 
			view nodes 
				stencil: [ :each |
					| element |
					element := BlElement new.
					element 	
						geometry: BlEllipseGeometry new;
						border: (BlBorder paint: Color black width: 1);
						size: 10@10;
						constraintsDo: [ :constraints | constraints padding: (BlInsets all: 5).
					each = self ifTrue: [element background: Color gray] ifFalse: [element background:  Color white]  ].
					element ];
				with: (self withDeepCollect: #ancestors) asSet.
			view edges connectToAll: #ancestors.
			view layout tree]
]

{ #category : #'*GToolkit4Git' }
IceCommit >> gtCommitsFor: aView [
	<gtView>
	^ aView columnedList 
		title: 'Ancestors' translated;
		items: [ self commits ];
		priority: 20;
		column: 'Timestamp' text: [ :aCommit | aCommit timeStamp asStringYMDHM ] width: 120;
		column: 'Commit' text: #shortId width: 70;
		column: 'Author' text: #author;
		column: 'Description' text: #comment
]

{ #category : #'*GToolkit4Git' }
IceCommit >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList 
		priority: 9;
		title: 'Details' translated;
		items: [ {
			'Commit'  -> ('[' , self shortId , '] ' , self commit id).
			'Parents' -> (self ancestors collect: #shortId) asCommaString.
			'Author'  -> self author.
			'Date'    -> self timeStamp asStringYMDHM.
			'Tags'    -> self tagNames asCommaString.
			'Comment' -> self comment.
			'Status'  -> self status.
			'URL' -> ((ZnUrl new scheme: #https; host: self repository origin host) / self repository origin projectPath / #commit / self id) } ];
		column: 'Property' text: #key width: 150;
		column: 'Value' text: #value;
		send: #value
]
