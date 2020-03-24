Extension { #name : #IceMerge }

{ #category : #'*GToolkit4Git' }
IceMerge >> gtInspectorMergeWindowIn: composite [
	<gtInspectorPresentationOrder:20>
	composite morph 
		title: 'Merge';
		display: [    
			|mergeMorph|
			 mergeMorph := (IceTipMergeMorph forMerger: self).
		    mergeMorph
		        fromDescription: self sourceDescription;
		        toDescription: self targetDescription.
			 mergeMorph ]
]
