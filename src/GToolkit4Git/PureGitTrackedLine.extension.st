Extension { #name : #PureGitTrackedLine }

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> asKumpelGraphElement [
	| vertices maxExtent |
	maxExtent := 0.
	vertices := Array
			streamContents: [ :out | 
				self positionsInVersions
					doWithIndex: [ :lineNumber :index | 
						lineNumber = 0
							ifFalse: [ | startPoint endPoint |
								startPoint := ((index - 1)
										* (self class versionWidth + self class versionMargin))
										@ ((lineNumber - 1) * self class lineHeight).
								endPoint := startPoint translateBy: self class versionWidth @ 0.
								maxExtent := maxExtent max: endPoint.
								out
									nextPut: startPoint;
									nextPut: endPoint ] ] ].
	vertices := vertices
			, (vertices reversed
					collect: [ :point | point translateBy: 0 @ self class lineHeight ]).
	^ BlElement new
		size: (maxExtent translateBy: 0 @ 5);
		geometry: (BlPolygonGeometry vertices: vertices);
		background: Color blue
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtContentsFor: composite context: context [
	<gtView>
	| gitFile |
	context navigation
		previousObjectSuchThat: [ :object | 
			(object isKindOf: PureGitFile) 
				or: [ object isKindOf: PureGitTrackedFile ] ]
		do: [ :object | gitFile := object file ]
		ifAbsent: [ ^ composite empty ].
	gitFile ifNil: [ ^ composite empty ].
	^ composite forward
		title: 'Contents';
		priority: 40;
		object: [ gitFile ];
		view: #gtEditorFor:
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtLineFor: aView [
	<gtView>
	^ aView textEditor 
		title: 'Line';
		priority: 1;
		text: [ self line ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtViewGraphFor: composite [
	<gtView>
	^ composite explicit
		title: 'Graph';
		priority: 20;
		stencil: [ self asKumpelGraphElement asCanvassableElement ]
]
