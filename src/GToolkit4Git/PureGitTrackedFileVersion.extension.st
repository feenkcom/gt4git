Extension { #name : #PureGitTrackedFileVersion }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileVersion >> gtLineOwnershipEvolutionFor: composite [
	<gtView>
	^ composite explicit
		title: 'Kumpel';
		priority: 60;
		tooltip: 'Show line history over time';
		stencil: [ | container |
			container := BlElement new.
			trackedFile uniqueTrackedLines
				do: [ :trackedLine | 
					| element |
					element := trackedLine asKumpelGraphElement.
					element
						background: (self trackedFile colorForAuthor: (trackedFile authorOfTrackedLine: trackedLine)).
					element
						border: (self trackedFile colorForAuthor: (trackedFile authorOfTrackedLine: trackedLine)).
					container addChild: element ].
			container
				size: ((trackedFile versions size *  (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
							- PureGitTrackedLine versionMargin)
						@ (PureGitTrackedLine lineHeight * trackedFile maxLinesCount).
			container
				addChild: (BlElement new
						background: (Color black alpha: 0.3);
						zIndex: 100;
						size: PureGitTrackedLine versionWidth @ (PureGitTrackedLine lineHeight * lines size);
						relocate: ((versionNumber - 1)
											* (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
										@ 0).
			container beInSeparateCompositionLayer asCanvassableElement
				margin: (BlInsets all: 10) ]
]
